//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public class NetworkManager {
    public let urlSession: URLSession

    public let authenticator: Authenticator

    public var configuration: Configuration {
        authenticator.configuration
    }

    public init(configuration: Configuration, urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.authenticator = Authenticator(configuration: configuration, urlSession: urlSession)
    }

    public func publisher<Response: Decodable>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { [self] endpoint in
                urlSession.publisher(for: endpoint)
            }
            .retry(1, when: { error in
                if case let HTTPError.invalidResponse(httpStatusCode) = error {
                    return httpStatusCode == .unauthorized || httpStatusCode == .forbidden
                }
                return false
            }, doBefore: { [weak self] in
                self?.authenticator.invalidateToken()
            })
            .eraseToAnyPublisher()
    }

    public func publisher(for endpoint: Endpoint<Void>) -> AnyPublisher<Void, Swift.Error> {
        return authenticator.validToken(onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { [self] endpoint in
                urlSession.publisher(for: endpoint)
            }
            .retry(1, when: { error in
                if case let HTTPError.invalidResponse(httpStatusCode) = error {
                    return httpStatusCode == .unauthorized || httpStatusCode == .forbidden
                }
                return false
            }, doBefore: { [weak self] in
                self?.authenticator.invalidateToken()
            })
            .eraseToAnyPublisher()
    }
}
