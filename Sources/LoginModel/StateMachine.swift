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
        case start              // initial state
        case pushedToServer     // send(configuration:Configuration, phoneNumber:String) was called on Endpoint
        case waitingForCode     // previous call was successful
        case sendCode           // loginWith(configuration:Configuration, otp: String) was called on Endpoint
        case loggedIn           // previous call was successful
        case deletingAccount    // delete(configuration:Configuration, phoneNumber:String) was called on Endpoint
        case error              // an error occured
    }
    
    public enum Event {
        case enterPhoneNumber   // User gives phone number textfield focus
        case sendingPhoneNumber // User has tapped button "Request Code"
        case enterCode          // User gives code textfield focus
        case loggingIn          // User has tapped button "Login"
        case trashAccount       // User has tapped button "Delete"
        case success            // 'Login' or 'Delete Account' was successfully executed
        case failure            // Handle an occurred error
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
            default:
                return nil
            }
        case .pushedToServer:
            switch event {
            case .enterPhoneNumber: return .pushedToServer
            case .sendingPhoneNumber: return .waitingForCode
            case .enterCode: return .sendCode
            case .failure: return .error
            default:
                return nil
            }
        case .waitingForCode:
            switch event {
            case .enterPhoneNumber: return .pushedToServer
            case .sendingPhoneNumber: return .pushedToServer
            case .enterCode: return .waitingForCode
            case .loggingIn: return .sendCode
            case .failure: return .error
            case .trashAccount: return .deletingAccount
            default:
                return nil
            }

        case .sendCode:
            switch event {
            case .success: return .loggedIn
            case .failure: return .error
            case .loggingIn: return .waitingForCode
            default:
                return nil
            }
        case .loggedIn:
            switch event {
            case .enterPhoneNumber, .success: return .start
            case .trashAccount: return .deletingAccount
            default:
                return nil
            }
        case .deletingAccount:
            switch event {
            case .trashAccount, .enterPhoneNumber, .success: return .start
            case .failure: return .error
            default:
                return nil
            }
        case .error:
            switch event {
                // got an error while sending event
            case .sendingPhoneNumber: return .pushedToServer
            case .loggingIn: return .waitingForCode
            case .trashAccount: return .deletingAccount
            case .enterPhoneNumber: return .start
                
            default:
                return nil
            }
        }
    }
}
