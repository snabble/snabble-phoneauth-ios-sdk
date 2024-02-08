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
    func startAuthorization(countryCallingCode: CountryCallingCode, phoneNumber: String) async throws -> String
    func startAuthorization(phoneNumber: String) async throws -> String
    func login(phoneNumber: String, OTP: String) async throws -> AppUser?
    func delete(phoneNumber: String) async throws
}

public protocol PhoneAuthDelegate: AnyObject {
    func phoneAuth(_ phoneAuth: PhoneAuth, didReceiveAppUser: AppUser)
}

public protocol PhoneAuthDataSource: AnyObject {
    func appUserId(forConfiguration configuration: Configuration) -> AppUser?
}

public class PhoneAuth {
    public var configuration: Configuration
    public weak var delegate: PhoneAuthDelegate?
    public weak var dataSource: PhoneAuthDataSource?
    
    private let networkManager: NetworkManager
    
    public init(configuration: Configuration, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.networkManager = NetworkManager(urlSession: urlSession)
        self.networkManager.authenticator.delegate = self
    }
}

extension PhoneAuth: PhoneAuthProviding {
    public func startAuthorization(countryCallingCode: CountryCallingCode, phoneNumber: String) async throws -> String {
        try await startAuthorization(phoneNumber: countryCallingCode.internationalPhoneNumber(phoneNumber))
    }
    
    public func startAuthorization(phoneNumber: String) async throws -> String {
        let endpoint = Endpoints.Phone.auth(
            configuration: configuration.toDTO(),
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
                    continuation.resume(with: .success(phoneNumber))
                }
        }
    }
    
    @discardableResult
    public func login(countryCallingCode: CountryCallingCode, phoneNumber: String, OTP: String) async throws -> AppUser? {
        try await login(phoneNumber: countryCallingCode.internationalPhoneNumber(phoneNumber), OTP: OTP)
    }
    
    @discardableResult
    public func login(phoneNumber: String, OTP: String) async throws -> AppUser? {
        let endpoint = Endpoints.Phone.login(
            configuration: configuration.toDTO(),
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
    
    public func delete(countryCallingCode: CountryCallingCode, phoneNumber: String) async throws {
        try await delete(phoneNumber: countryCallingCode.internationalPhoneNumber(phoneNumber))
    }
    
    public func delete(phoneNumber: String) async throws {
        let endpoint = Endpoints.Phone.delete(
            configuration: configuration.toDTO(),
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

extension PhoneAuth: AuthenticatorDelegate {
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        dataSource?.appUserId(forConfiguration: configuration.fromDTO())?.toDTO()
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        delegate?.phoneAuth(self, didReceiveAppUser: appUser.fromDTO())
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        configuration.projectId
    }
}
