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
    
    func testCountryCalledCode() throws {
        let country: CountryCallingCode = .init(countryCode: "DE", callingCode: 49)
        
        XCTAssertEqual(country.countryCode, "DE")
        XCTAssertEqual(country.callingCode, 49)
        
        XCTAssertEqual(country.flagSymbol, "🇩🇪")
        XCTAssertEqual(country.id, "DE")
    }
    
    func testArrayExtensions() throws {
        let countries = CountryCallingCode.default
        XCTAssertEqual(countries.countryCodes, ["AT", "BE", "CH", "DE", "DK", "ES", "FR", "GR", "IT", "NL", "LU", "LI"])
        XCTAssertEqual(countries.country(forCode: "DE"), countries[3])
    }
}
