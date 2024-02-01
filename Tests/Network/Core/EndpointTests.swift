//
//  EndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-15.
//

import XCTest
@testable import SnabbleNetwork

struct Mock: Decodable {
    let name: String
}

final class EndpointTests: XCTestCase {

    let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
    func testDefaultInit() throws {
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            return Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.path, "/apps/mock")
        XCTAssertEqual(endpoint.environment, .production)
        XCTAssertEqual(endpoint.headerFields, [:])
        XCTAssertNil(endpoint.token)
    }

    func testEnvironmentParameter() throws {
        var configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        var endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.environment, .production)

        configuration = .init(appId: "1", appSecret: "2", environment: .staging, projectId: "1")
        endpoint = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.environment, .staging)

        configuration = .init(appId: "1", appSecret: "2", environment: .testing, projectId: "1")
        endpoint = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.environment, .testing)
    }

    func testPathParameter() throws {
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        var endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.path, "/apps/mock")

        endpoint = .init(path: "/foobar/mock2", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.path, "/foobar/mock2")
    }

    func testMethodParameter() throws {
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        var endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.method, .get(nil))

        endpoint = .init(path: "/apps/mock", method: .get([.init(name: "foobar", value: "1")]), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.method, .get([.init(name: "foobar", value: "1")]))

        endpoint = .init(path: "/apps/mock", method: .head, configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertEqual(endpoint.method, .head)
    }

    func testToken() throws {
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        var endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get(nil), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        XCTAssertNil(endpoint.token)
        XCTAssertNil(try! endpoint.urlRequest().allHTTPHeaderFields?["Authentication"])

        endpoint.token = .init(id: "1", value: "accessToken", issuedAt: Date(), expiresAt: .distantFuture)
        XCTAssertNotNil(endpoint.token)
        XCTAssertEqual(try! endpoint.urlRequest().allHTTPHeaderFields?["Authorization"], "Bearer accessToken")
    }

    func testGETURLRequestWithQueryItems() throws {
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get([
            .init(name: "foobar", value: "1"),
            .init(name: "barfoo", value: "100")
        ]), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock?barfoo=100&foobar=1")
        XCTAssertEqual(urlRequest.httpBody, nil)
    }

    func testGETURLRequestWithQueryItemsOverwriteHeaderfields() throws {
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        var endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .get([
            .init(name: "foobar", value: "1"),
            .init(name: "barfoo", value: "100")
        ]), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        endpoint.headerFields = ["Content-Type": "application/text"]
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/text"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock?barfoo=100&foobar=1")
        XCTAssertEqual(urlRequest.httpBody, nil)
    }

    func testPOSTURLRequest() throws {
        let jsonString = """
        [
            {
                "name": "Taylor Swift",
                "age": 26
            },
            {
                "name": "Justin Bieber",
                "age": 25
            }
        ]
        """
        let jsonData = Data(jsonString.utf8)
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .post(jsonData, [
            .init(name: "foobar", value: "1"),
            .init(name: "barfoo", value: "100")
        ]), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock?barfoo=100&foobar=1")
        XCTAssertEqual(urlRequest.httpBody, jsonData)
    }

    func testPUTURLRequest() throws {
        let jsonString = """
        [
            {
                "name": "Taylor Swift",
                "age": 26
            },
            {
                "name": "Justin Bieber",
                "age": 25
            }
        ]
        """
        let jsonData = Data(jsonString.utf8)
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .put(jsonData), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "PUT")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock")
        XCTAssertEqual(urlRequest.httpBody, jsonData)
    }

    func testPATCHURLRequest() throws {
        let jsonString = """
        [
            {
                "name": "Taylor Swift",
                "age": 26
            },
            {
                "name": "Justin Bieber",
                "age": 25
            }
        ]
        """
        let jsonData = Data(jsonString.utf8)
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .patch(jsonData), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "PATCH")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock")
        XCTAssertEqual(urlRequest.httpBody, jsonData)
    }

    func testDELETEURLRequest() throws {
        let jsonString = """
        [
            {
                "name": "Taylor Swift",
                "age": 26
            },
            {
                "name": "Justin Bieber",
                "age": 25
            }
        ]
        """
        let jsonData = Data(jsonString.utf8)
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .delete(jsonData), configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "DELETE")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock")
        XCTAssertEqual(urlRequest.httpBody, jsonData)
    }

    func testHEADURLRequest() throws {
        let configuration: Configuration = .init(appId: "1", appSecret: "2", environment: .production, projectId: "1")
        let endpoint: Endpoint<Mock> = .init(path: "/apps/mock", method: .head, configuration: configuration) { _ in
            Mock(name: "foobar")
        }
        let urlRequest = try! endpoint.urlRequest()
        XCTAssertEqual(urlRequest.httpMethod, "HEAD")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(urlRequest.url, "https://api.snabble.io/apps/mock")
        XCTAssertEqual(urlRequest.httpBody, nil)
    }
}
