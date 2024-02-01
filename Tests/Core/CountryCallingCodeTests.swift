//
//  CountryCallingCodeTests.swift
//  
//
//  Created by Uwe Tilemann on 23.05.23.
//

import XCTest

@testable import SnabbleNetwork
@testable import SnabblePhoneAuth

final class CountryCallingCodeTests: XCTestCase {
    
    func testCountry() throws {
        let country: CountryCallingCode = .init(countryCode: "DE", callingCode: 49, trunkPrefix: 0)
        
        XCTAssertEqual(country.countryCode, "DE")
        XCTAssertEqual(country.callingCode, 49)
        
        let phoneNumber = "0177 123 45 67"
        XCTAssertEqual(country.internationalPhoneNumber(phoneNumber), "+491771234567")
        XCTAssertEqual(country.prettyPrint(phoneNumber), "+49 177 123 45 67")
    }
}
