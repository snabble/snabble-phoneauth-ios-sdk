//
//  PhoneAuthEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-08.
//

import XCTest
@testable import SnabbleNetwork
import Combine

final class PhoneAuthEndpointTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    var appUser: AppUser?

    func disableTestRequest() async throws {
        let networkManager = NetworkManager(configuration: .init(
            appId: "demo-app-me0eeK",
            appSecret: "UTXSZZTN6PEA5QHAY5JBVPUSIRNQGEZADHFUBBGZQMOCC7RNGDSA====",
            environment: .development)
        )
        networkManager.authenticator.delegate = self

        let endpoint = Endpoints.Phone.auth(configuration: networkManager.configuration, phoneNumber: "+4915119695415")

        let expectation = expectation(description: "phoneAuth")
        networkManager.publisher(for: endpoint).sink {
            print("completion: ", $0)
            expectation.fulfill()
        } receiveValue: { response in
            print("response: ",response)
        }
        .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 600)
    }

}

extension PhoneAuthEndpointTests: AuthenticatorDelegate {
    func authenticator(_ authenticator: Authenticator, projectIdForEnvironment: Environment) -> String? {
        "demo"
    }

    func authenticator(_ authenticator: Authenticator, appUserUpdated appUser: AppUser?) {
        self.appUser = appUser
    }

    func authenticator(_ authenticator: Authenticator, appUserForEnvironment: Environment) -> AppUser? {
        appUser
    }
}
