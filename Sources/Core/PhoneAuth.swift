//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2024-02-01.
//

import Foundation
import SnabbleNetwork
import Combine

enum PhoneAuthError: Swift.Error {
    case phoneNumberInvalid
    case unknown
}

public protocol PhoneAuthProviding {
    func startAuthorization(phoneNumber: String) async throws
    func login(phoneNumber: String, OTP: String) async throws -> SnabbleNetwork.AppUser?
    func delete(phoneNumber: String) async throws
}

public protocol PhoneAuthDelegate: AnyObject {
    func phoneAuth(_ phoneAuth: PhoneAuth, didReceiveAppUser: SnabbleNetwork.AppUser)
}

public class PhoneAuth {
    public var configuration: SnabbleNetwork.Configuration
    public weak var delegate: PhoneAuthDelegate?
    
    private let networkManager: NetworkManager
    
    init(configuration: SnabbleNetwork.Configuration, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.networkManager = NetworkManager(urlSession: urlSession)
        self.networkManager.authenticator.delegate = self
    }
}

extension PhoneAuth: PhoneAuthProviding {
    public func startAuthorization(countryCallingCode: CountryCallingCode, phoneNumber: String) async throws {
        try await startAuthorization(phoneNumber: countryCallingCode.internationalPhoneNumber(phoneNumber))
    }
    
    public func startAuthorization(phoneNumber: String) async throws {
        let endpoint = Endpoints.Phone.auth(
            configuration: configuration,
            phoneNumber: phoneNumber
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkManager.publisher(for: endpoint)
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
    
    public func login(countryCallingCode: CountryCallingCode, phoneNumber: String, OTP: String) async throws -> SnabbleNetwork.AppUser? {
        try await login(phoneNumber: countryCallingCode.internationalPhoneNumber(phoneNumber), OTP: OTP)
    }
    
    public func login(phoneNumber: String, OTP: String) async throws -> SnabbleNetwork.AppUser? {
        let endpoint = Endpoints.Phone.login(
            configuration: configuration,
            phoneNumber: phoneNumber,
            OTP: OTP
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkManager.publisher(for: endpoint)
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
    
    public func delete(countryCallingCode: CountryCallingCode, phoneNumber: String) async throws {
        try await delete(phoneNumber: countryCallingCode.internationalPhoneNumber(phoneNumber))
    }
    
    public func delete(phoneNumber: String) async throws {
        let endpoint = Endpoints.Phone.delete(
            configuration: configuration,
            phoneNumber: phoneNumber
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkManager.publisher(for: endpoint)
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

extension PhoneAuth: AuthenticatorDelegate {
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        AppUser(id: configuration.appId, secret: configuration.appSecret)
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        delegate?.phoneAuth(self, didReceiveAppUser: appUser)
    }
    
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        configuration.projectId
    }
}
