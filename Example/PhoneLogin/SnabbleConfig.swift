//
//  SnabbleConfig.swift
//  SnabbleSampleApp
//
//  Created by Andreas Osberghaus on 06.09.22.
//  Copyright © 2022 snabble. All rights reserved.
//

import Foundation

//import SnabbleCore
/// General config data for using the snabble.
/// Applications must call `Snabble.setup(config: completion:)` with an instance of this struct before they make their first API call.
public struct Config {
    /// the appID assigned by snabble
    public let appId: String
    /// the environment  to use
    public let environment: Snabble.Environment
    /// the secrect assigned by snabble, used to retrieve authorization tokens
    public let secret: String

    /// Initialize the configuration for Snabble
    /// - Parameters:
    ///   - appId: Provide your personal `appId`
    ///   - secret: The secret matching your `appId`
    ///   - environment: Choose an environment you want to use
    public init(appId: String, secret: String, environment: Snabble.Environment = .production) {
        self.appId = appId
        self.environment = environment
        self.secret = secret
    }
}

public class Snabble {
    
    /**
     * Environment in which the App should work
     *
     * Possible values are `testing`, `staging` and `production`.
     * `production` is the default in the sdk
     */
    public enum Environment: String, CaseIterable, Equatable {
        case testing
        case staging
        case production
        
        public var urlString: String {
            switch self {
            case .testing:
                return "https://api.snabble-testing.io"
            case .staging:
                return "https://api.snabble-staging.io"
            case .production:
                return "https://api.snabble.io"
            }
        }
        
        public var name: String {
            switch self {
            case .testing, .staging:
                return rawValue
            case .production:
                return "prod"
            }
        }
        
        /// Verification for the `appId`
        ///
        /// The secret and `appId` can only be used for demo cases
        public var secret: String {
            switch self {
            case .testing:
                return "BWXJ2BFC2JRKRNW4QBASQCF2TTANPTVPOXQJM57JDIECZJQHZWOQ===="
            case .staging:
                return "P3SZXAPPVAZA5JWYXVKFSGGBN4ZV7CKCWJPQDMXSUMNPZ5IPB6NQ===="
            case .production:
                return "2TKKEG5KXWY6DFOGTZKDUIBTNIRVCYKFZBY32FFRUUWIUAFEIBHQ===="
            }
        }
    }
}

extension Config {
    static var appId: String {
        "snabble-sdk-demo-app-oguh3x"
    }

    static var production: Self {
        let environment: Snabble.Environment = .production
        return .init(
            appId: appId,
            secret: environment.secret,
            environment: environment
        )
    }

    static var staging: Self {
        let environment: Snabble.Environment = .staging
        return .init(
            appId: appId,
            secret: environment.secret,
            environment: environment
        )
    }

    static var testing: Self {
        let environment: Snabble.Environment = .testing
        return .init(
            appId: appId,
            secret: environment.secret,
            environment: environment
        )
    }
    
    static func config(for environment: Snabble.Environment) -> Self {
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
