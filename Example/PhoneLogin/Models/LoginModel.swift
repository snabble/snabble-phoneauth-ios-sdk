//
//  LoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 15.05.23.
//

import Foundation
import UIKit

import SnabblePhoneAuth
import SnabbleNetwork

class LoginModel: ObservableObject, PhoneLoginDelegate {
    var countries: [SnabblePhoneAuth.CountryCallingCode]?
    let phoneModel = PhoneLoginModel()
    
    private var _appUser: AppUser?

    /// The current valid `AppUser` or nil if not yet set or the `reset()` function was called.
    /// The appUser will set by implementing the `AuthenticatorDelegate` protocol.
    public var appUser: AppUser? {
        get {
            _appUser
        }
        set {
            if newValue?.id != _appUser?.id {
                _appUser = newValue
                DispatchQueue.main.async {
                    if UserDefaults.logActions {
                        if let user = newValue {
                            ActionLogger.shared.add(log: LogAction(action: "appID", info: user.id))
                        } else {
                            ActionLogger.shared.add(log: LogAction(action: "remove appID"))
                        }
                    }
                   UserDefaults.appUser = newValue
                }
            }
        }
    }

    init() {
        _appUser = UserDefaults.appUser
        countries = loadJSON("Countries")
        phoneModel.delegate = self
        phoneModel.authenticator.delegate = self
    }

    public var configuration: Configuration {
        return .testing
    }
    
    public var selectedCountry: String? {
        get {
            UserDefaults.selectedCountry
        }
        set {
            UserDefaults.selectedCountry = newValue
        }
    }
    
    func supportedCountries() -> [SnabblePhoneAuth.CountryCallingCode]? {
        countries
    }
    
    public var phoneNumber: String? {
        get {
            UserDefaults.phoneNumber
        }
        set {
            UserDefaults.phoneNumber = newValue
        }
    }

}

extension LoginModel: AuthenticatorDelegate {
    /// Provide the `Authenticator` with a stored AppUser struct or nil if not yet exists or was resetted.
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        self.appUser
    }
    
    /// make sure to store/save an updated `AppUser`
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        self.appUser = appUser
    }
    
    /// Provide the `Authenticator` with a project identifier.
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        Configuration.projectId
    }
}

// MARK: - State changes
extension LoginModel: StateChanging {
    
    func leaveState(_ state: StateMachine.State) {
        if UserDefaults.logActions {
            ActionLogger.shared.add(log: LogAction(action: "leave state", info: "\(state)"))
        }
        if case .deletingAccount = state {
            appUser = nil
            phoneModel.resetAppUser()
        }
    }
    
    func enterState(_ state: StateMachine.State) {
        if UserDefaults.logActions {
            ActionLogger.shared.add(log: LogAction(action: "enter state", info: "\(state)"))
        }
    }
}
