//
//  PhoneLoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import Combine
import SnabbleNetwork

public class PhoneLoginModel: ObservableObject {
    
    private let stateMachine: StateMachine
    private let networkManager: NetworkManager
    
    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?

    @Published public var country: CountryCallingCode {
        didSet {
            UserDefaults.selectedCountry = country.countryCode
        }
    }
    
    @Published public var phoneNumber: String = ""
    
    @Published public var receivedCode: String = ""
    
    @Published public var isLoggingIn: Bool = false
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
#if DEBUG
    public var logActions = true
#else
    public var logAction = false
#endif
    
    public init(networkManager: NetworkManager, stateMachine: StateMachine = StateMachine(state: .start), logActions: Bool? = nil) {
        self.country = CountryCallingCodes.defaultCountry
        
        if let savedCountry = UserDefaults.selectedCountry, let country = CountryCallingCodes.country(for: savedCountry) {
            self.country = country
        }
        self.stateMachine = stateMachine
        self.networkManager = networkManager

        if let flag = logActions {
            self.logActions = flag
        }
        self.state = stateMachine.state
        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
    }
    
    public var canSendPhoneNumber: Bool {
        guard phoneNumber.count > 2 else {
            return false
        }
        return state == .error || state == .start || state == .waitingForCode
    }
    
    public var canLogin: Bool {
        guard pinCode.count == 4 else {
            return false
        }
        return state == .error || state == .waitingForCode
    }
    
    var timeStamp: Date?
    
    public var canRequestCode: Bool {
        if canSendPhoneNumber {
            if let timestamp = timeStamp, timestamp + 30 < .now {
                return false
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
            ActionLogger.shared.add(log: LogAction(action: "request code for", info: "\(pinCode)"))
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
        let endpoint = Endpoints.Phone.auth(configuration: networkManager.configuration, phoneNumber: dialString)

        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
                
                print("completion: ", completion)

                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }

            } receiveValue: { response in
                print("response: ", response)
            }
    }

    private func sendCode() {
        let endpoint = Endpoints.Phone.login(configuration: networkManager.configuration, phoneNumber: dialString, OTP: pinCode)

        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }

                print("completion: ", completion)
            
            } receiveValue: { response in
                print("response: ", response)
            }
    }
}

// MARK: - State changes
extension PhoneLoginModel {

    func leaveState(_ state: StateMachine.State) {
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "leave state", info: "\(state)"))
        }
        if case .sendCode = state, case .pushedToServer = state {
            isLoggingIn = false
        }
    }
    
    func enterState(_ state: StateMachine.State) {
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "enter state", info: "\(state)"))
        }
        
        if case .loggedIn = state {
            self.isLoggingIn = true
        }
        if case .waitingForCode = state {
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
