//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public class NetworkManager {
    public let authenticator: Authenticator

    public init(urlSession: URLSession = .shared) {
        self.authenticator = Authenticator(urlSession: urlSession)
    }

    public var urlSession: URLSession {
        authenticator.urlSession
    }

    public func publisher<Response>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(withConfiguration: endpoint.configuration)
            .map { token -> Endpoint<Response> in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { [self] endpoint in
                urlSession.dataTaskPublisher(for: endpoint)
            }
            .retryOnce(if: { error in
                if case let HTTPError.invalid(response) = error {
                    let statusCode = response.httpStatusCode
                    return statusCode == .unauthorized || statusCode == .forbidden
                }
                return false
            }, doBefore: { [weak self] in
                self?.authenticator.invalidateToken()
            })
            .handleEvents(receiveOutput: { [weak self] response in
                if let appUser = response as? AppUser {
                    self?.authenticator.updateAppUser(appUser)
                }
            })
            .eraseToAnyPublisher()
    }
}
