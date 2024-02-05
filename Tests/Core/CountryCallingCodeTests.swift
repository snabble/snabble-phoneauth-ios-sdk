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
        let country: CountryCallingCode = .init(countryCode: "DE", callingCode: 49, trunkPrefix: 0, locale: .init(identifier: "de-DE"))
        
        XCTAssertEqual(country.countryCode, "DE")
        XCTAssertEqual(country.callingCode, 49)
        XCTAssertEqual(country.internationalCode, 00)
        
        let phoneNumber = "0177 123 45 67"
        XCTAssertEqual(country.internationalPhoneNumber(phoneNumber), "+491771234567")
        XCTAssertEqual(country.prettyPrint(phoneNumber), "+49 177 123 45 67")
        
        XCTAssertEqual(country.flagSymbol, "🇩🇪")
        XCTAssertEqual(country.countryName, "Deutschland")
        XCTAssertEqual(country.id, "DE")
    }
    
    func testArrayExtensions() throws {
        let countries = CountryCallingCode.default
        XCTAssertEqual(countries.countryCodes, ["AT", "BE", "CH", "DE", "DK", "ES", "FR", "GR", "IT", "NL", "LU", "LI"])
        XCTAssertEqual(countries.country(forCode: "DE"), countries[3])
    }
    
    func testInternalPhoneNumberWithTrunkPrefix() throws {
        let code = CountryCallingCode(countryCode: "DE", callingCode: 49, trunkPrefix: 0)
        
        XCTAssertEqual(code.internationalPhoneNumber("015119695415"), "+4915119695415")
    }
    
    func testInternalPhoneNumberWithoutTrunkPrefix() throws {
        let code = CountryCallingCode(countryCode: "DE", callingCode: 49, trunkPrefix: nil)
        
        XCTAssertEqual(code.internationalPhoneNumber("015119695415"), "+49015119695415")
    }
}
