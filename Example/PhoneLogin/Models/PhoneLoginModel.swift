//
//  PhoneLoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Combine
import Foundation
import SnabblePhoneAuth

enum FakeEndpointError: Error {
    case phoneNumberError
    case loginError
}

extension FakeEndpointError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .phoneNumberError:
            return NSLocalizedString("Error: PhoneNumber endpoint failed.", comment: "")
        case .loginError:
            return NSLocalizedString("Error: Login endpoint failed.", comment: "")
        }
    }
}

class LoginService: ObservableObject {
    private let session: URLSession
    
    var userInfo: [String: Any] = [:]
    
    init(session: URLSession) {
        self.session = session
    }
    
    func send(phoneNumber: String) -> AnyPublisher<PhoneResponse, Error> {
        if let error = userInfo["error"] as? FakeEndpointError, error == .phoneNumberError {
            return session.publisher(for: .send(phoneNumber: phoneNumber), userInfo: userInfo)
        } else {
            return session.publisher(for: .send(phoneNumber: phoneNumber))
        }
    }
    
    func loginWith(code: String) -> AnyPublisher<Login, Error> {
        if let error = userInfo["error"] as? FakeEndpointError, error == .loginError {
            return session.publisher(for: .loginWith(code: code), userInfo: userInfo)
        } else {
            return session.publisher(for: .loginWith(code: code))
        }
    }
}

class PhoneLoginModel: ObservableObject {
    
    private let stateMachine: StateMachine
    private let loginService: LoginService

    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?

    let countryCode: String
    var phoneNumber: String = ""
    var pinCode: String = ""
    
    var userInfo: [String: Any] = [:] {
        didSet {
            loginService.userInfo = userInfo
        }
    }

    @Published var receivedCode: String = ""
    @Published var isLoggingIn: Bool = false
    @Published var canLogin: Bool = false
    
    @Published
    var errorMessage: String = "" {
        didSet {
            if !errorMessage.isEmpty {
                print("error received: \(errorMessage)")
            }
        }
    }
    
    @Published var state: StateMachine.State {
        willSet { leaveState(state) }
        didSet { enterState(state) }
    }
    
    init(countryCode: String = "+49", stateMachine: StateMachine, loginService: LoginService) {
        self.countryCode = countryCode
        self.stateMachine = stateMachine
        self.loginService = loginService
        
        self.state = stateMachine.state
        
        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
        print("using \(SnabblePhoneAuth.name)")
    }
}

extension PhoneLoginModel {
    
    func verifyPhoneNumber(_ string: String) -> String {
        guard !string.hasPrefix("+") else {
            return string
        }
        return "\(countryCode) \(string)"
    }
    
    func sendPhoneNumber(_ string: String) {
        phoneNumber = verifyPhoneNumber(string)
        stateMachine.tryEvent(.sendingPhoneNumber)
    }
    
    func loginWithCode(_ string: String) {
        pinCode = string
        stateMachine.tryEvent(.loggingIn)
    }
    
    func reset() {
        pinCode = ""
        self.errorMessage = ""
        stateMachine.tryEvent(.enterPhoneNumber)
    }
    
    func logout() {
        reset()
    }

    private func pushToServer() {
        loginCancellable = loginService.send(phoneNumber: phoneNumber)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] (completion) in
                guard let strongSelf = self else { return }
                
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }

                strongSelf.receivedCode = response.code
                strongSelf.stateMachine.tryEvent(.sendingPhoneNumber)
            })
    }

    private func sendCode() {
        loginCancellable = loginService.loginWith(code: pinCode)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] (completion) in
                guard let strongSelf = self else { return }
                
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }
            }, receiveValue: { [weak self] login in
                guard let strongSelf = self else { return }

                print("received login: \(login)")
                if login.code == strongSelf.receivedCode {
                    strongSelf.stateMachine.tryEvent(.success)
                } else {
                    strongSelf.errorMessage = "Der eingegebene Code ist falsch!"
                    strongSelf.stateMachine.tryEvent(.enterCode)
                }
            })
    }
}

// MARK: - State changes
extension PhoneLoginModel {

    func leaveState(_ state: StateMachine.State) {
        if case .sendCode = state, case .pushedToServer = state {
            isLoggingIn = false
        }
    }
    
    func enterState(_ state: StateMachine.State) {
        if case .waitingForCode = state {
            self.canLogin = true
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
