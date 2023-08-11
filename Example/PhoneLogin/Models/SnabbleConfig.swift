//
//  SnabbleConfig.swift
//  SnabbleSampleApp
//
//  Created by Andreas Osberghaus on 06.09.22.
//  Copyright © 2022 snabble. All rights reserved.
//

import Foundation
import SnabbleNetwork

extension Configuration {
    static var appId: String {
        "snabble-sdk-demo-app-oguh3x"
    }
    /// A `String`with the project identifier used for backend communication
    public static var projectId: String {
        "snabble-sdk-demo-beem8n"
    }
    static var testing: Self {
        return .init(
            appId: appId,
            appSecret: "BWXJ2BFC2JRKRNW4QBASQCF2TTANPTVPOXQJM57JDIECZJQHZWOQ====",
            environment: .testing
        )
    }
    
    static var staging: Self {
        return .init(
            appId: appId,
            appSecret: "P3SZXAPPVAZA5JWYXVKFSGGBN4ZV7CKCWJPQDMXSUMNPZ5IPB6NQ====",
            environment: .staging
        )
    }

    static var production: Self {
        return .init(
            appId: appId,
            appSecret: "2TKKEG5KXWY6DFOGTZKDUIBTNIRVCYKFZBY32FFRUUWIUAFEIBHQ====",
            environment: .production
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