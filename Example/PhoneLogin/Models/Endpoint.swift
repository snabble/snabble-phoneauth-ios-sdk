//
//  Endpoint.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 24.01.23.
//

import Foundation
import Combine

protocol EndpointKind {
    associatedtype RequestData
    
    static func prepare(_ request: inout URLRequest, with data: RequestData)
    static func prepare(_ request: inout URLRequest)
}

enum EndpointKinds {
    enum Public: EndpointKind {
        static func prepare(_ request: inout URLRequest) {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        static func prepare(_ request: inout URLRequest, with _: Void) {
            self.prepare(&request)
        }
    }
}

struct Endpoint<Kind: EndpointKind, Response: Decodable> {
    var path: String
    var queryItems = [URLQueryItem]()
}

extension Endpoint {
    var components : URLComponents {
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

struct NetworkResponse<Wrapped: Decodable>: Decodable {
    var result: Wrapped
    
    enum CodingKeys: String, CodingKey {
        case result = "args"
    }
}

enum URLSessionError: Error {
    case invalidEndpoint
}

extension URLSession {
    func publisher<K, R>(
        for endpoint: Endpoint<K, R>,
        using requestData: K.RequestData,
        decoder: JSONDecoder = .init()
    ) -> AnyPublisher<R, Error> {
        guard let request = endpoint.makeRequest(with: requestData) else {
            return Fail(error: URLSessionError.invalidEndpoint)
                .eraseToAnyPublisher()
        }

        return dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: NetworkResponse<R>.self, decoder: decoder)
            .map(\.result)
            .eraseToAnyPublisher()
    }

    func publisher<K, R>(
        for endpoint: Endpoint<K, R>,
        decoder: JSONDecoder = .init(),
        userInfo: [String: Any]? = nil
    ) -> AnyPublisher<R, Error> {
        guard let request = endpoint.makeRequest() else {
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

extension Endpoint where Kind == EndpointKinds.Public, Response == PhoneResponse {
    static func send(phoneNumber: String) -> Self {
        let code = Int.random(in: 1000..<9999)
        
        return Endpoint(path: "delay/4", queryItems: [
            URLQueryItem(name: "phoneNumber", value: phoneNumber.replacingOccurrences(of: "+", with: "00")),
            URLQueryItem(name: "code", value: "\(code)")
        ])
    }
}

extension Endpoint where Kind == EndpointKinds.Public, Response == Login {
    static func loginWith(code: String) -> Self {
        return Endpoint(path: "delay/2", queryItems: [
            URLQueryItem(name: "code", value: code)
        ])
    }
}

struct PhoneResponse: Decodable {
    let phoneNumber: String
    let code: String
}

struct Login: Decodable {
    let code: String
}
