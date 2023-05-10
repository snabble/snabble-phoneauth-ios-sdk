//
//  Environment.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

public enum Environment {
    case testing
    case staging
    case production

    var headerFields: [String: String] {
        return [
            "Content-Type": "application/json"
        ]
    }

    var baseURL: URL {
        switch self {
        case .testing:
            return "https://api.snabble-testing.io"
        case .staging:
            return "https://api.snabble-staging.io"
        case .production:
            return "https://api.snabble.io"
        }
    }
}
