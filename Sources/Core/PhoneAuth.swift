//
//  PhoneAuth.swift
//  
//
//  Created by Andreas Osberghaus on 2024-02-01.
//

import Foundation
import SnabbleNetwork
import Combine

public protocol PhoneAuthProviding {
    func startAuthorization(phoneNumber: String) async throws -> String
    func login(phoneNumber: String, OTP: String) async throws -> AppUser?
    func delete(phoneNumber: String) async throws
}

public protocol PhoneAuthDelegate: AnyObject {
    func phoneAuth(_ phoneAuth: PhoneAuth, didReceiveAppUser: AppUser)
}

public protocol PhoneAuthDataSource: AnyObject {
    func appUserId(forConfiguration configuration: Configuration) -> AppUser?
    func projectId(forConfiguration configuration: Configuration) -> String?
}

public class PhoneAuth {
    public weak var delegate: PhoneAuthDelegate?
    public weak var dataSource: PhoneAuthDataSource?
    
    private let networkManager: NetworkManager
    
    public var configuration: Configuration {
        networkManager.configuration.fromDTO()
    }
    
    public init(configuration: Configuration, urlSession: URLSession = .shared) {
        self.networkManager = NetworkManager(
            configuration: configuration.toDTO(),
            urlSession: urlSession
        )
        self.networkManager.delegate = self
    }
}

extension PhoneAuth: PhoneAuthProviding {
    public func startAuthorization(phoneNumber: String) async throws -> String {
        let endpoint = Endpoints.Phone.auth(
            appId: configuration.appId,
            phoneNumber: phoneNumber
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkManager.publisher(for: endpoint)
                .mapHTTPErrorIfPossible()
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()

                } receiveValue: { _ in
                    continuation.resume(with: .success(phoneNumber))
                }
        }
    }
    
    @discardableResult
    public func login(phoneNumber: String, OTP: String) async throws -> AppUser? {
        let endpoint = Endpoints.Phone.login(
            appId: configuration.appId,
            phoneNumber: phoneNumber,
            OTP: OTP
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkManager.publisher(for: endpoint)
                .mapHTTPErrorIfPossible()
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()

                } receiveValue: { value in
                    continuation.resume(with: .success(value?.fromDTO()))
                }
        }
    }
    
    public func delete(phoneNumber: String) async throws {
        let endpoint = Endpoints.Phone.delete(
            appId: configuration.appId,
            phoneNumber: phoneNumber
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkManager.publisher(for: endpoint)
                .mapHTTPErrorIfPossible()
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()

                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                }
        }
    }
}

extension Publisher {
    func mapHTTPErrorIfPossible() -> AnyPublisher<Self.Output, Error> {
        mapError {
            guard let error = $0 as? SnabbleNetwork.HTTPError else {
                return $0
            }
            return error.fromDTO()
        }
        .eraseToAnyPublisher()
    }
}

extension PhoneAuth: NetworkManagerDelegate {
    public func networkManager(_ networkManager: SnabbleNetwork.NetworkManager, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        dataSource?.appUserId(forConfiguration: configuration.fromDTO())?.toDTO()
    }
    
    public func networkManager(_ networkManager: SnabbleNetwork.NetworkManager, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        delegate?.phoneAuth(self, didReceiveAppUser: appUser.fromDTO())
    }
    
    public func networkManager(_ networkManager: SnabbleNetwork.NetworkManager, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String? {
        dataSource?.projectId(forConfiguration: configuration.fromDTO())
    }
}
