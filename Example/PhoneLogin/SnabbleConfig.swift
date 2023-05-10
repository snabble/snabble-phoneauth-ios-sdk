//
//  SnabbleConfig.swift
//  SnabbleSampleApp
//
//  Created by Andreas Osberghaus on 06.09.22.
//  Copyright © 2022 snabble. All rights reserved.
//

import Foundation

import SnabbleNetwork
import SnabblePhoneAuth

extension UserDefaults {
    private enum Keys {
        static let appUserIdKey = "appUserId"
        static let appUserSecretKey = "appUserSecret"
    }

    public class var appUserID: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appUserIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appUserIdKey)
            UserDefaults.standard.synchronize()
        }
    }
    public class var appUserSecret: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.appUserSecretKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appUserSecretKey)
            UserDefaults.standard.synchronize()
        }
    }

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

public class Snabble {
    
    public let loginManager: PhoneLoginModel

    init(configuration: Configuration) {
        self.loginManager = PhoneLoginModel(configuration: configuration)
        // if DEBUG logActions is set to true by default
//        self.loginManager.logActions = false
        
        self.loginManager.authenticator.delegate = self
    }
}

extension Snabble: AuthenticatorDelegate {
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        UserDefaults.appUser
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        UserDefaults.appUser = appUser
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        "demo"
    }
}

extension Configuration {
    static var appId: String {
        "snabble-sdk-demo-app-oguh3x"
    }

    static var production: Self {
        return .init(
            appId: appId,
            appSecret: "2TKKEG5KXWY6DFOGTZKDUIBTNIRVCYKFZBY32FFRUUWIUAFEIBHQ====",
            environment: .production
        )
    }

    static var staging: Self {
        return .init(
            appId: appId,
            appSecret: "P3SZXAPPVAZA5JWYXVKFSGGBN4ZV7CKCWJPQDMXSUMNPZ5IPB6NQ====",
            environment: .staging
        )
    }

    static var testing: Self {
        return .init(
            appId: appId,
            appSecret: "BWXJ2BFC2JRKRNW4QBASQCF2TTANPTVPOXQJM57JDIECZJQHZWOQ====",
            environment: .testing
        )
    }
    
    static func config(for environment: Environment) -> Self {
        switch environment {
        case .testing:
            return Self.testing
        case .staging:
            return Self.staging
        case .production:
            return Self.production
        }
    }
}
