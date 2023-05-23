//
//  File.swift
//  
//
//  Created by Uwe Tilemann on 23.05.23.
//

import Foundation
import Combine

import SnabbleNetwork
import SnabblePhoneAuth

class LoginModel: PhoneLoginDelegate {

    var countries: [SnabblePhoneAuth.CountryCallingCode]?
    let phoneModel = PhoneLoginModel()
    
    var appUser: AppUser?

    init() {
        appUser = AppUser(id: "1", secret: "abc")
        countries = CountryProvider.defaultCountries
        
        phoneModel.delegate = self
        phoneModel.authenticator.delegate = self
    }

    var selectedCountry: String? {
        get {
            countries?.first?.id
        }
        set { }
    }
    
    func supportedCountries() -> [SnabblePhoneAuth.CountryCallingCode]? {
        return countries
    }

    var configuration: Configuration {
        return Configuration(appId: "4711", appSecret: "Tailor Swift", environment: .testing)
    }
    
    var phoneNumber: String?
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
        return "test"
    }
}

