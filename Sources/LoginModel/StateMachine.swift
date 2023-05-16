//
//  StateMachine.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 19.01.23.
//

import Foundation
import Combine

/// The `StateMachine` defines how a login process will react on events and store the current state which will be triggert by the success or failure of these events.
open class StateMachine {
    
    /// The current `State`
    public enum State {
        /// initial state
        case start
        
        /// send(configuration:Configuration, phoneNumber:String) was called on Endpoint
        case pushedToServer
        
        /// previous call was successful
        case waitingForCode
        
        /// loginWith(configuration:Configuration, otp: String) was called on Endpoint
        case sendCode
        
        /// previous call was successful
        case loggedIn
        
        /// delete(configuration:Configuration, phoneNumber:String) was called on Endpoint
        case deletingAccount
        
        /// an error occured
        case error
    }
    
    /// The user triggers one of these `Event` types
    public enum Event {
        /// User gives phone number textfield focus
        case enterPhoneNumber
        
        /// User has tapped button "Request Code""
        case sendingPhoneNumber
        
        /// User gives code textfield focus/
        case enterCode
        
        /// User has tapped button "Login"
        case loggingIn
        
        /// User has tapped button "Delete""
        case trashAccount
        
        /// 'Login' or 'Delete Account' was successfully executed
        case success
        
        /// Handle an occurred error
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
    
    /// An `Event` is triggered by a user action, like a button click.
    @discardableResult func tryEvent(_ event: Event) -> Bool {
        guard let state = nextState(for: event) else {
            return false
        }
        
        self.state = state
        return true
    }
    
    /// Discover the possible nextState for an `Event` or nil if state is final
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
