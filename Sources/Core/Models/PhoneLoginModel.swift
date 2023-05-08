//
//  PhoneLoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import Combine

public class PhoneLoginModel: ObservableObject {
    
    private let stateMachine: StateMachine
    private let loginService: LoginService
    
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
    private var phoneResponse: PhoneResponse?
    
    @Published public var state: StateMachine.State {
        willSet { leaveState(state) }
        didSet { enterState(state) }
    }

    @Published public var pinCode: String = ""
    
    public var userInfo: [String: Any] = [:] {
        didSet {
            loginService.userInfo = userInfo
        }
    }

    public init(stateMachine: StateMachine = StateMachine(state: .start), loginService: LoginService = LoginService(session: .shared)) {
        self.country = CountryCallingCodes.defaultCountry
        
        if let savedCountry = UserDefaults.selectedCountry, let country = CountryCallingCodes.country(for: savedCountry) {
            self.country = country
        }
        self.stateMachine = stateMachine
        self.loginService = loginService
        
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
    
    public var canRequestCode: Bool {
        if canSendPhoneNumber {
            if let timestamp = phoneResponse?.timestamp, timestamp + 30 < .now {
                return false
            }
            return true
        } else {
            return false
        }
    }
    public var isWaiting: Bool {
        state == .pushedToServer
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
        stateMachine.tryEvent(.sendingPhoneNumber)
    }

    public func loginWithCode(_ string: String) {
        pinCode = string
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
        loginCancellable = loginService.send(phoneNumber: dialString)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] (completion) in
                    guard let strongSelf = self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                        
                    case .failure(let error):
                        strongSelf.errorMessage = error.localizedDescription
                        strongSelf.stateMachine.tryEvent(.failure)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.phoneResponse = response
                    
                    strongSelf.receivedCode = response.code
                    strongSelf.stateMachine.tryEvent(.sendingPhoneNumber)
                })
    }

    private func sendCode() {
        loginCancellable = loginService.loginWith(code: pinCode)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] (completion) in
                    guard let strongSelf = self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                        
                    case .failure(let error):
                        strongSelf.errorMessage = error.localizedDescription
                        strongSelf.stateMachine.tryEvent(.failure)
                    }
                },
                receiveValue: { [weak self] login in
                    guard let strongSelf = self else { return }
                    
                    print("received login: \(login)")
                    if login.code == strongSelf.receivedCode {
                        strongSelf.stateMachine.tryEvent(.success)
                    } else {
                        strongSelf.errorMessage = "Der eingegebene Code ist falsch!"
                        strongSelf.stateMachine.tryEvent(.loggingIn)
                    }
                })
    }
}

// MARK: - State changes
extension PhoneLoginModel {

    func leaveState(_ state: StateMachine.State) {
        print("leave state: <\(state)>")
        if case .sendCode = state, case .pushedToServer = state {
            isLoggingIn = false
        }
    }
    
    func enterState(_ state: StateMachine.State) {
        print("enter state: <\(state)>")
        if case .waitingForCode = state {
            //self.canLogin = true
        }
        if case .loggedIn = state {
            self.isLoggingIn = true
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
