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
    private let configuration: Configuration
    
    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?

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
    
    public private(set) var appUser: AppUser? {
        didSet {
            let storedAppUser = UserDefaults.appUser
            if appUser?.id != storedAppUser?.id {
                DispatchQueue.main.async {
                    if self.logActions {
                        if let user = self.appUser {
                            ActionLogger.shared.add(log: LogAction(action: "appID", info: user.id))
                        } else {
                            ActionLogger.shared.add(log: LogAction(action: "remove appID"))
                        }
                    }
                    UserDefaults.appUser = self.appUser
                }
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

    @Published public var waitTimer: WaitTimer
    let projectID: String
    
    public init(configuration: Configuration, projectID: String, logActions: Bool? = nil) {

        self.projectID = projectID
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

        self.appUser = UserDefaults.appUser

        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
        if self.logActions, let appUser = self.appUser {
            ActionLogger.shared.add(log: LogAction(action: "appID", info: appUser.id))
        }
        self.authenticator.delegate = self
    }
}

extension PhoneLoginModel: AuthenticatorDelegate {
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        self.appUser
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        self.appUser = appUser
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        self.projectID
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
        guard canLogin else {
            return
        }
        
        pinCode = string
        
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "Login with OTP", info: "\(pinCode)"))
        }
        stateMachine.tryEvent(.loggingIn)
    }
    public func login() {
        loginWithCode(pinCode)
    }

    public func deleteAccount() {
        guard UserDefaults.appUser != nil, let number = UserDefaults.phoneNumber, !number.isEmpty else {
            return
        }
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "Deleting Account", info: "\(dialString)"))
        }
        stateMachine.tryEvent(.trashAccount)
    }
    
    public func reset() {
        if timerIsRunning {
            waitTimer.stop()
        }
        self.appUser = nil
        self.phoneNumber = ""
        self.pinCode = ""
        self.errorMessage = ""
        UserDefaults.phoneNumber = nil

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
        
        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
                
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
                
            } receiveValue: { _ in
            }
    }
    
    private func delete() {
        
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "deleting account..."))
        }
        let endpoint = Endpoints.Phone.delete(configuration: self.configuration, phoneNumber: dialString)
        
        deleteCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    ActionLogger.shared.add(log: LogAction(action: "Account deleted"))
                    strongSelf.reset()

                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }
                
            } receiveValue: { _ in
                
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
        if case .pushedToServer = state {
            errorMessage = ""
            pushToServer()
        }
        if case .sendCode = state {
            errorMessage = ""
            sendCode()
        }
        if case .deletingAccount = state {
            errorMessage = ""
            delete()
        }
   }
    
}
