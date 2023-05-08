//
//  TokenEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import XCTest
@testable import SnabbleNetwork
import Combine

final class TokenEndpointTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testRequest() async throws {
        let networkManager = NetworkManager(app: .init(
            id: "demo-app-me0eeK",
            secret: "UTXSZZTN6PEA5QHAY5JBVPUSIRNQGEZADHFUBBGZQMOCC7RNGDSA====",
            environment: .development)
        )
        networkManager.authenticator.delegate = self

        let endpoint = Endpoints.Token.get(
            app: networkManager.app,
            appUser: .init(
                id: "25e0af5a-8214-4884-a6d1-0f72f3dbb060",
                secret: "fcbUbyXtmAIKvcbhYaKzD9gjnaOz6XikqrC6zmP+BTI="),
            projectId: "demo")

        let expectation = expectation(description: "token")
        networkManager.publisher(for: endpoint).sink {
            print("completion: ", $0)
            expectation.fulfill()
        } receiveValue: { response in
            print("response: ",response)
        }
        .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 60)
    }
}

extension TokenEndpointTests: AuthenticatorDelegate {
    func authenticator(_ authenticator: Authenticator, projectIdForEnvironment: Environment) -> String? {
        "demo"
    }

    func authenticator(_ authenticator: Authenticator, appUserUpdated appUser: AppUser?) {
        print("appUser: ", appUser)
    }

    func authenticator(_ authenticator: Authenticator, appUserForEnvironment: Environment) -> AppUser? {
        nil
    }
}

