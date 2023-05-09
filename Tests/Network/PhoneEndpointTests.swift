//
//  PhoneEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-09.
//

import XCTest
@testable import SnabbleNetwork
import Combine

final class PhoneEndpointTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

        var appUser: AppUser?

        func testRequest() async throws {
            let configuration = Configuration(
                appId: "demo-app-me0eeK",
                appSecret: "UTXSZZTN6PEA5QHAY5JBVPUSIRNQGEZADHFUBBGZQMOCC7RNGDSA====",
                environment: .testing
            )
            let networkManager = NetworkManager()
            networkManager.authenticator.delegate = self

            let endpoint = Endpoints.Phone.auth(configuration: configuration, phoneNumber: "+4915119695415")

            let expectation = expectation(description: "appUser")
            networkManager.publisher(for: endpoint).sink {
                print("completion: ", $0)
                switch $0 {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
                expectation.fulfill()
            } receiveValue: { response in
                print("response: ",response)
            }
            .store(in: &cancellables)

            await fulfillment(of: [expectation], timeout: 600)
        }
}

extension PhoneEndpointTests: AuthenticatorDelegate {
    func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        appUser
    }

    func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        "demo"
    }

    func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        self.appUser = appUser
    }
}
