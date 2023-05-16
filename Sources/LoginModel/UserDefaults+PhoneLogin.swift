//
//  UserDefaults+PhoneLogin.swift
//  
//
//  Created by Uwe Tilemann on 11.05.23.
//

import Foundation
import SnabbleNetwork

extension UserDefaults {
    private enum Keys {
        static let phoneNumber = "phoneNumber"
        static let appUserIdKey = "appUserId"
        static let appUserSecretKey = "appUserSecret"
    }

    /// If the phone number was successfully send to the backend to request an OTP the phone number is stored.
    public class var phoneNumber: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.phoneNumber)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.phoneNumber)
            UserDefaults.standard.synchronize()
        }
    }

    /// The stored `appUserID`.
    public class var appUserID: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appUserIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appUserIdKey)
            UserDefaults.standard.synchronize()
        }
    }

    /// The stored `appUserSecret`.
    public class var appUserSecret: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appUserSecretKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appUserSecretKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// The stored `AppUser`.
    public class var appUser: AppUser? {
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
}
