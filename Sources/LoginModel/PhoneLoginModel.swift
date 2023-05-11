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

public class WaitTimer: ObservableObject {
    @Published public var isRunning: Bool = false
    
    let publisher: Timer.TimerPublisher
    var waitCancellable: Cancellable?
    @Published public var startTime: Date?
    @Published public var endTime: Date?

    init(interval: TimeInterval = 1.0) {
        self.publisher = Timer.publish(every: interval, tolerance: 0.5, on: .main, in: .default)
    }
    public func start() {
        isRunning = true
        
        startTime = .now
        endTime = nil
        print("timer started: \(String(describing: startTime))")

        waitCancellable = self.publisher
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] timer in
                self?.stop()
            })
    }

    public func stop() {
        waitCancellable = nil
        isRunning = false
        endTime = .now
        print("timer stopped: \(String(describing: endTime))")
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
        
#if DEBUG
    public var logActions = true
#else
    public var logAction = false
#endif
    public var authenticator: Authenticator {
        return networkManager.authenticator
    }

    @Published public var waitTimer: WaitTimer
    
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
        
        self.waitTimer = WaitTimer(interval: 30)
        
        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
    }
}

extension PhoneLoginModel {
    public var codeWasSendOnce: Bool {
        guard let string = UserDefaults.phoneNumber else {
            return false
        }
        return !string.isEmpty
    }
    
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
    
    public var isWaiting: Bool {
        state == .pushedToServer || state == .sendCode
    }

    public var timerIsRunning: Bool {
        return waitTimer.isRunning
    }

    public var canRequestCode: Bool {
        if canSendPhoneNumber {
            guard !timerIsRunning else {
                return false
            }
            return true
        } else {
            return false
        }
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

    public func startTimer() {
        guard !timerIsRunning else {
            return
        }
        waitTimer.start()
    }

    private func pushToServer() {

        let endpoint = Endpoints.Phone.auth(configuration: self.configuration, phoneNumber: dialString)
        startTimer()
        
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
            startTimer()
        }
        if case .error = state {
            //self.timeStamp = nil
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
