//
//  UserDefaults+PhoneLogin.swift
//  
//
//  Created by Uwe Tilemann on 11.05.23.
//

import Foundation

import SnabblePhoneAuth
import SnabbleNetwork

extension PhoneLoginModel {
    func resetAppUser() {
        UserDefaults.phoneNumber = nil
        UserDefaults.appUser = nil
    }
}

extension UserDefaults {
    private enum Keys {
        static let logActions = "logActions"
        static let selectedCountry = "country"
        static let phoneNumber = "phoneNumber"
        static let appUserIdKey = "appUserId"
        static let appUserSecretKey = "appUserSecret"
    }

    /// A boolean to control the logging of debug messages
    class var logActions: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.logActions)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.logActions)
        }
    }

    /// If the phone number was successfully send to the backend to request an OTP the phone number is stored.
    class var phoneNumber: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.phoneNumber)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.phoneNumber)
            UserDefaults.standard.synchronize()
        }
    }

    /// The stored `appUserID`.
    class var appUserID: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appUserIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appUserIdKey)
            UserDefaults.standard.synchronize()
        }
    }

    /// The stored `appUserSecret`.
    class var appUserSecret: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appUserSecretKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appUserSecretKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// The stored `AppUser`.
    class var appUser: AppUser? {
        get {
            if let userID = appUserID, let secret = appUserSecret {
                return AppUser(id: userID, secret: secret)
            }
            return nil
        }
        set {
            appUserID = newValue?.id
            appUserSecret = newValue?.secret
        }
    }
    
    /// The stored `selectedCountry`.
    class var selectedCountry: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.selectedCountry)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.selectedCountry)
        }
    }
    
}
