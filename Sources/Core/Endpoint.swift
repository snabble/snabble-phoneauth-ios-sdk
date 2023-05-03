//
//  Endpoint.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 24.01.23.
//

import Foundation
import Combine

public protocol EndpointKind {
    associatedtype RequestData
    
    static func prepare(_ request: inout URLRequest, with data: RequestData)
    static func prepare(_ request: inout URLRequest)
}

public enum EndpointKinds {
    public enum Public: EndpointKind {
        public static func prepare(_ request: inout URLRequest) {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        public static func prepare(_ request: inout URLRequest, with _: Void) {
            self.prepare(&request)
        }
    }
}

public struct Endpoint<Kind: EndpointKind, Response: Decodable> {
    var path: String
    var queryItems = [URLQueryItem]()
}

public extension Endpoint {
    var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "httpbin.org"
        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        return components
    }

    func makeRequest(with data: Kind.RequestData? = nil) -> URLRequest? {
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url)
        if let data = data {
            Kind.prepare(&request, with: data)
        } else {
            Kind.prepare(&request)
        }
        return request
    }
}

public struct NetworkResponse<Wrapped: Decodable>: Decodable {
    var result: Wrapped
    
    enum CodingKeys: String, CodingKey {
        case result = "args"
    }
}

public enum URLSessionError: Error {
    case invalidEndpoint
}

public extension URLSession {
    func publisher<K, R>(
        for endpoint: Endpoint<K, R>,
        using requestData: K.RequestData? = nil,
        decoder: JSONDecoder = .init(),
        userInfo: [String: Any]? = nil
    ) -> AnyPublisher<R, Error> {
        guard let request = endpoint.makeRequest(with: requestData) else {
            return Fail(error: URLSessionError.invalidEndpoint)
                .eraseToAnyPublisher()
        }
        if let error = userInfo?["error"] as? Error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: NetworkResponse<R>.self, decoder: decoder)
            .map(\.result)
            .eraseToAnyPublisher()
    }
}
