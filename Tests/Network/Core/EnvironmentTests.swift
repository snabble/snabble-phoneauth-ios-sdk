//
//  EnvironmentTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-15.
//

import XCTest
@testable import SnabbleNetwork

final class EnvironmentTests: XCTestCase {
    func testDevelopmentBaseURL() throws {
        let environment: Environment = .testing
        XCTAssertEqual(environment.baseURL, "https://api.snabble-testing.io")
        XCTAssertEqual(environment.headerFields, [
            "Content-Type": "application/json"
        ])
    }

    func testStagingBaseURL() throws {
        let environment: Environment = .staging
        XCTAssertEqual(environment.baseURL, "https://api.snabble-staging.io")
        XCTAssertEqual(environment.headerFields, [
            "Content-Type": "application/json"
        ])
    }

    func testProductionBaseURL() throws {
        let environment: Environment = .production
        XCTAssertEqual(environment.baseURL, "https://api.snabble.io")
        XCTAssertEqual(environment.headerFields, [
            "Content-Type": "application/json"
        ])
    }
}
