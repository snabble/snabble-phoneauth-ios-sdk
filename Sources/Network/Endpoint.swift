//
//  Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import SnabbleModels

/// A namespace for types that serve as `Endpoint`.
///
/// The various endpoints defined as extensions on ``Endpoint``.
public enum Endpoints {
    static var jsonDecoder: JSONDecoder {
        let jsonDecoder: JSONDecoder = .init()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        return jsonDecoder
    }
}

public struct Endpoint<Response> {
    public let method: HTTPMethod
    public let path: String
    public let configuration: Configuration

    public let parse: (Data) throws -> Response

    var token: Token?
    var headerFields: [String: String] = [:]

    public init(path: String, method: HTTPMethod, configuration: Configuration, parse: @escaping (Data) throws -> Response) {
        self.path = path
        self.method = method
        self.configuration = configuration
        self.parse = parse
    }

    var domain: Domain {
        configuration.domain
    }

    enum Error: Swift.Error {
        case invalidRequestError(String)
    }
}

extension Endpoint {
    public func urlRequest() throws -> URLRequest {
        var components = URLComponents(
            url: domain.baseURL,
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
            throw Error.invalidRequestError("baseURL: \(domain.baseURL), path: \(path)")
        }

        var request = URLRequest(url: url)

        switch method {
        case .post(let data, _), .put(let data), .patch(let data), .delete(let data):
            request.httpBody = data
        default:
            request.httpBody = nil
        }

        let headerFields = domain.headerFields.merging(headerFields, uniquingKeysWith: { _, new in new })
        request.allHTTPHeaderFields = headerFields

        if let token = token {
            request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
        }

        request.httpMethod = method.value
        request.cachePolicy = .useProtocolCachePolicy

        return request
    }
}
