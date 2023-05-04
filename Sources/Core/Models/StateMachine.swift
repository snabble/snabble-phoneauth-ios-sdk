//
//  StateMachine.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 19.01.23.
//

import Foundation
import Combine

open class StateMachine {
    
    public enum State {
        case start              // start what else
        case pushedToServer     // send(phoneNumber:String) was called on Endpoint
        case waitingForCode     // previous call was successful
        case sendCode           // loginWith(code: String) was called on Endpoint
        case loggedIn           // previous call was successful
        case error              // an error occured
    }
    
    public enum Event {
        case enterPhoneNumber   // User gives phone number textfield focus
        case sendingPhoneNumber // User has tapped button "Request Code"
        case enterCode          // User give code textfield focus
        case loggingIn          // User has tapped button "Login"
        case success
        case failure
    }
    
    public private(set) var state: State {
        didSet { stateSubject.send(self.state) }
    }
    private let stateSubject: PassthroughSubject<State, Never>
    public let statePublisher: AnyPublisher<State, Never>
    
    public init(state: State) {
        self.state = state
        self.stateSubject = PassthroughSubject<State, Never>()
        self.statePublisher = self.stateSubject.eraseToAnyPublisher()
    }
    
}

// MARK: - State changes

public extension StateMachine {
    
    @discardableResult func tryEvent(_ event: Event) -> Bool {
        guard let state = nextState(for: event) else {
            return false
        }
        
        self.state = state
        return true
    }
    
    private func nextState(for event: Event) -> State? {
        switch state {
        case .start:
            switch event {
            case .sendingPhoneNumber, .enterPhoneNumber: return .pushedToServer
            case .enterCode, .loggingIn, .success, .failure: return nil
            }
        case .pushedToServer:
            switch event {
            case .enterPhoneNumber: return .pushedToServer
            case .sendingPhoneNumber: return .waitingForCode
            case .enterCode: return .sendCode
            case .loggingIn: return nil
            case .success: return nil
            case .failure: return .error
            }
        case .waitingForCode:
            switch event {
            case .enterPhoneNumber: return .pushedToServer
            case .sendingPhoneNumber: return .pushedToServer
            case .enterCode: return .waitingForCode
            case .loggingIn: return .sendCode
            case .success: return nil
            case .failure: return .error
            }

        case .sendCode:
            switch event {
            case .success: return .loggedIn
            case .enterCode: return .waitingForCode
            case .failure: return .error
            case .enterPhoneNumber, .sendingPhoneNumber, .loggingIn:
                return nil
            }
        case .loggedIn:
            switch event {
            case .enterPhoneNumber, .success: return .start
            case .sendingPhoneNumber, .enterCode, .loggingIn, .failure: return nil
            }
        case .error:
            switch event {
            case .sendingPhoneNumber: return .start
            case .enterPhoneNumber, .enterCode, .loggingIn, .success, .failure: return nil
            }
        }
    }
}
