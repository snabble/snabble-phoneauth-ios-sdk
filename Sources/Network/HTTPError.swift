//
//  HTTPError.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-24.
//

import Foundation

public enum HTTPError: LocalizedError {
    case invalid(HTTPURLResponse)
    case unknown(URLResponse)
    case unexpected(Error)
    
    public var errorDescription: String? {
        switch self {
        case let .invalid(response):
            return "Error: statusCode: \(response.httpStatusCode.rawValue)"
        case let .unknown(response):
            return "Error: unknown \(response)"
        case .unexpected:
            return "Error: unexpected should not happen"
        }
    }
}
