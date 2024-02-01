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
        let country: CountryCallingCode = .init(countryCode: "DE", callingCode: "49")
        
        XCTAssertEqual(country.countryCode, "DE")
        XCTAssertEqual(country.callingCode, "49")
        
        let phoneNumber = "0177 123 45 67"
        XCTAssertEqual(country.dialString(phoneNumber), "+491771234567")
        XCTAssertEqual(country.prettyPrint(phoneNumber), "+49 177 123 45 67")
    }

    class Provider: CountryProviding {
        func supportedCountries() -> [SnabblePhoneAuth.CountryCallingCode]? {
            return [.init(countryCode: "DE", callingCode: "49")]
        }
        
        var selectedCountry: String? {
            get { "DE" }
            set(newValue) {
                guard newValue == "DE" else {
                    fatalError("country is not DE")
                }
            }
        }
    }

    func testCountryProviding() throws {
        let provider = Provider()
        
        XCTAssertEqual(provider.selectedCountry, "DE")
        XCTAssertEqual(provider.supportedCountries()?.count, 1)
    }
}
