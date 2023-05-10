//
//  Authenticator.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Dispatch
import Combine

public protocol AuthenticatorDelegate: AnyObject {
    func authenticator(_ authenticator: Authenticator, appUserForConfiguration configuration: Configuration) -> AppUser?
    func authenticator(_ authenticator: Authenticator, appUserUpdated appUser: AppUser)

    func authenticator(_ authenticator: Authenticator, projectIdForConfiguration configuration: Configuration) -> String
}

public class Authenticator {
    public let urlSession: URLSession

    public weak var delegate: AuthenticatorDelegate?

    enum Error: Swift.Error {
        case missingAuthenticator
        case missingProject
    }

    public private(set) var token: Token?

    private let queue: DispatchQueue = .init(label: "io.snabble.network.authenticator.\(UUID().uuidString)")

    private var refreshPublisher: AnyPublisher<Token, Swift.Error>?

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func invalidateToken() {
        token = nil
    }

    private func validateAppUser(withConfiguration configuration: Configuration) -> AnyPublisher<AppUser, Swift.Error> {
        // scenario 1: app instance is registered
        if let appUser = delegate?.authenticator(self, appUserForConfiguration: configuration) {
            return Just(appUser)
                .setFailureType(to: Swift.Error.self)
                .eraseToAnyPublisher()
        }

        // scenario 2: we have to register the app instance
        let endpoint = Endpoints.AppUser.post(
            configuration: configuration
        )
        let publisher = urlSession.dataTaskPublisher(for: endpoint)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.token = response.token
                self?.delegate?.authenticator(self!, appUserUpdated: response.appUser)
            }, receiveCompletion: { _ in })
            .map { $0.appUser }
            .eraseToAnyPublisher()
        return publisher
    }

    func validToken(
        withConfiguration configuration: Configuration,
        forceRefresh: Bool = false
    ) -> AnyPublisher<Token, Swift.Error> {
        return queue.sync { [weak self] in
            guard let self = self else {
                return Fail(error: Error.missingAuthenticator)
                    .eraseToAnyPublisher()
            }
            // scenario 1: we're already loading a new token
            if let publisher = self.refreshPublisher {
                return publisher
            }

            // scenario 2: we already have a valid token and don't want to force a refresh
            if let token = self.token, token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we need a new token
            guard let projectId = self.delegate?.authenticator(self, projectIdForConfiguration: configuration) else {
                return Fail(error: Error.missingProject)
                    .eraseToAnyPublisher()
            }

            let publisher = self.validateAppUser(withConfiguration: configuration)
                .map { appUser -> Endpoint<Token> in
                    return Endpoints.Token.get(
                        configuration: configuration,
                        appUser: appUser,
                        projectId: projectId
                    )
                }
                .tryMap { tokenEndpoint -> (URLSession, Endpoint<Token>) in
                    return (self.urlSession, tokenEndpoint)
                }
                .mapError { HTTPError.unexpected($0) }
                .flatMap { urlSession, endpoint in
                    return urlSession.dataTaskPublisher(for: endpoint).share()
                }
                .handleEvents(receiveOutput: { token in
                    self.token = token
                }, receiveCompletion: { _ in
                    self.queue.sync {
                        self.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self.refreshPublisher = publisher
            return publisher
        }
    }
}