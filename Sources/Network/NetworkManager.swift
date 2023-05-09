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
            .map { token -> Endpoint<Response> in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { [self] endpoint in
                return urlSession.dataTaskPublisher(for: endpoint)
                    .retryOnce(if: { error in
                        if case let HTTPError.invalidResponse(httpStatusCode) = error {
                            return httpStatusCode == .unauthorized || httpStatusCode == .forbidden
                        }
                        return false
                    }, doBefore: { [weak self] in
                        self?.authenticator.invalidateToken()
                    })
            }
            .handleEvents(receiveOutput: { [weak self] response in
                if let appUser = response as? AppUser {
                    self?.authenticator.delegate?.authenticator(self!.authenticator, appUserUpdated: appUser)
                }
            })
            .eraseToAnyPublisher()
    }
}
