//
//  File.swift
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

    func testRequest() async throws {
        let networkManager = NetworkManager(app: .init(
            id: "demo-app-me0eeK",
            secret: "UTXSZZTN6PEA5QHAY5JBVPUSIRNQGEZADHFUBBGZQMOCC7RNGDSA====",
            environment: .development)
        )
        networkManager.authenticator.delegate = self

        let endpoint = Endpoints.AppUser.post(app: networkManager.app, projectId: "demo")

        let expectation = expectation(description: "appUser")
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
