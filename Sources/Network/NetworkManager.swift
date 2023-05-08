//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ networkManager: NetworkManager, appCredentialsForRequest: URLRequest) -> String?
    func networkManager(_ networkManager: NetworkManager, projectSecretForRequest: URLRequest) -> String?
}

public class NetworkManager {
    public let urlSession: URLSession

    public weak var delegate: NetworkManagerDelegate?

    public let authenticator: Authenticator

    public var app: App {
        authenticator.app
    }

    public init(app: App, urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.authenticator = Authenticator(app: app, urlSession: urlSession)
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

//extension NetworkManager: AuthenticatorDelegate {
//    func authenticator(_ authenticator: Authenticator, didUpdateCredentials credentials: Credentials?) {
//        delegate?.networkManager(self, didUpdateCredentials: credentials)
//    }
//}
