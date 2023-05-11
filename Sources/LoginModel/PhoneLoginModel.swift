//
//  PhoneLoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import Combine
import SnabbleNetwork

extension UserDefaults {
    private enum Keys {
        static let phoneNumber = "phoneNumber"
    }

    public class var phoneNumber: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.phoneNumber)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.phoneNumber)
            UserDefaults.standard.synchronize()
        }
    }
}

public class PhoneLoginModel: ObservableObject {
    
    private let stateMachine: StateMachine
    private let networkManager: NetworkManager
    private let configuration: Configuration
    
    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?
    
    @Published public var country: CountryCallingCode {
        didSet {
            UserDefaults.selectedCountry = country.countryCode
        }
    }
    
    @Published public var phoneNumber: String = ""
    @Published public var errorMessage: String = "" {
        didSet {
            if !errorMessage.isEmpty {
                print("error received: \(errorMessage)")
            }
        }
    }
    
    @Published public var state: StateMachine.State {
        willSet { leaveState(state) }
        didSet { enterState(state) }
    }
    
    @Published public var pinCode: String = ""
    
    @Published public var timeStamp: Date? {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
#if DEBUG
    public var logActions = true
#else
    public var logAction = false
#endif
    public var authenticator: Authenticator {
        return networkManager.authenticator
    }
    
    public init(configuration: Configuration, logActions: Bool? = nil) {
        self.country = CountryCallingCodes.defaultCountry
        
        if let savedCountry = UserDefaults.selectedCountry, let country = CountryCallingCodes.country(for: savedCountry) {
            self.country = country
        }
        self.configuration = configuration
        self.networkManager = NetworkManager()
        
        if let flag = logActions {
            self.logActions = flag
        }
        
        let stateMachine: StateMachine
        
        if let number = UserDefaults.phoneNumber, !number.isEmpty {
            phoneNumber = number
            stateMachine = StateMachine(state: .waitingForCode)
        } else {
            stateMachine = StateMachine(state: .start)
        }
        self.stateMachine = stateMachine
        self.state = stateMachine.state
        
        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
    }
}

extension PhoneLoginModel {
    public var canSendPhoneNumber: Bool {
        guard phoneNumber.count > 2 else {
            return false
        }
        return state == .error || state == .start || state == .waitingForCode
    }
    
    public var canLogin: Bool {
        guard pinCode.count == 6 else {
            return false
        }
        return state == .error || state == .waitingForCode
    }

    public var isLoggedIn: Bool {
        state == .loggedIn
    }
    
    public var canRequestCode: Bool {
        if canSendPhoneNumber {
            if let timestamp = timeStamp {
                if timestamp + 30 < .now {
                    return false
                } else {
                    DispatchQueue.main.async {
                        self.timeStamp = nil
                    }
                }
            }
            return true
        } else {
            return false
        }
    }
    public var isWaiting: Bool {
        state == .pushedToServer || state == .sendCode
    }
}

extension PhoneLoginModel {
    public var dialString: String {
        return country.dialString(self.phoneNumber)
    }
    
    public var phoneNumberPrettyPrint: String {
        return country.prettyPrint(self.phoneNumber)
    }
}

extension PhoneLoginModel {

    public func sendPhoneNumber() {
        guard canRequestCode else {
            return
        }
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "request code for", info: "\(dialString)"))
        }
        stateMachine.tryEvent(.sendingPhoneNumber)
    }

    public func loginWithCode(_ string: String) {

        pinCode = string

        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "Login with OTP", info: "\(pinCode)"))
        }
        stateMachine.tryEvent(.loggingIn)
    }
    
    public func reset() {
        pinCode = ""
        self.errorMessage = ""
        stateMachine.tryEvent(.enterPhoneNumber)
    }
    
    public func logout() {
        reset()
    }

    private func pushToServer() {
        let endpoint = Endpoints.Phone.auth(configuration: self.configuration, phoneNumber: dialString)

        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
                
                print("completion: ", completion)

                switch completion {
                case .finished:
                    strongSelf.stateMachine.tryEvent(.sendingPhoneNumber)
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }

            } receiveValue: { _ in
            }
    }

    private func sendCode() {
        let endpoint = Endpoints.Phone.login(configuration: self.configuration, phoneNumber: dialString, OTP: pinCode)

        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    strongSelf.stateMachine.tryEvent(.success)
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }

                print("completion: ", completion)
            
            } receiveValue: { response in
                print("response: \(String(describing: response))")
            }
    }
}

// MARK: - State changes
extension PhoneLoginModel {

    func leaveState(_ state: StateMachine.State) {
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "leave state", info: "\(state)"))
        }
    }
    
    func enterState(_ state: StateMachine.State) {
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "enter state", info: "\(state)"))
        }
        
        if case .waitingForCode = state {
            UserDefaults.phoneNumber = self.phoneNumber
            self.timeStamp = .now
        }
        if case .error = state {
            self.timeStamp = nil
        }
        if case .pushedToServer = state {
            errorMessage = ""
            pushToServer()
        }
        if case .sendCode = state {
            errorMessage = ""
            sendCode()
        }
   }
    
}
