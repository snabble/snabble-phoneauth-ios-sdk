//
//  HTTPError.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-24.
//

import Foundation

public enum HTTPError {
    case invalidResponse(HTTPStatusCode)
    case unknownResponse(URLResponse)
    case unexpected(Error)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidResponse(httpStatusCode):
            return "Error: statusCode: \(httpStatusCode.rawValue))"
        case let .unknownResponse(response):
            return "Error: unknown \(response)"
        case .unexpected:
            return "Error: unexpected should not happen"
        }
    }
}
