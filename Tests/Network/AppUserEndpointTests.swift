import XCTest
@testable import SnabbleNetwork
import Combine

final class AppUserEndpointTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

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

        await fulfillment(of: [expectation], timeout: 5)
    }
}

extension AppUserEndpointTests: AuthenticatorDelegate {
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
