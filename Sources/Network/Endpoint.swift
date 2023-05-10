//
//  Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

/// A namespace for types that serve as `Endpoint`.
///
/// The various endpoints defined as extensions on ``Endpoint``.
public enum Endpoints {}

public struct Endpoint<Response> {
    public let method: HTTPMethod
    public let path: String
    public let configuration: Configuration

    var jsonDecoder: JSONDecoder = {
        let jsonDecoder: JSONDecoder = .init()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        return jsonDecoder
    }()

    var token: Token?
    var headerFields: [String: String] = [:]

    public init(path: String, method: HTTPMethod, configuration: Configuration) {
        self.path = path
        self.method = method
        self.configuration = configuration
    }

    private var environment: Environment {
        configuration.environment
    }

    enum Error: Swift.Error {
        case invalidRequestError(String)
    }
}

extension Endpoint {
    public func urlRequest() throws -> URLRequest {
        var components = URLComponents(
            url: environment.baseURL,
            resolvingAgainstBaseURL: false
        )
        components?.path = path

        switch method {
        case .get(let queryItems):
            components?.queryItems = queryItems?.sorted(by: \.name)
        case .post(_, let queryItems):
            components?.queryItems = queryItems?.sorted(by: \.name)
        default:
            break
        }

        guard let url = components?.url else {
            throw Error.invalidRequestError("baseURL: \(environment.baseURL), path: \(path)")
        }

        var request = URLRequest(url: url)

        switch method {
        case .post(let data, _), .put(let data), .patch(let data), .delete(let data):
            request.httpBody = data
        default:
            request.httpBody = nil
        }

        let headerFields = environment.headerFields.merging(headerFields, uniquingKeysWith: { _, new in new })
        request.allHTTPHeaderFields = headerFields

        if let token = token {
            request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
        }

        request.httpMethod = method.value
        request.cachePolicy = .useProtocolCachePolicy

        return request
    }
}