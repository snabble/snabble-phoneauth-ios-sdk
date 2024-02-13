//
//  CountryCallingCode.swift
//  
//
//  Created by Uwe Tilemann on 04.05.23.
//

import Foundation

public struct CountryCallingCode {
    public static var `default`: [CountryCallingCode] = loadJSON("countries")
    
    public let countryCode: String // eg. DE, AT, CH
    public let callingCode: UInt // eg. 49, 43
    
    public var flagSymbol: String? {
        countryCode.flagSymbol
    }
    
    public init(
        countryCode: String,
        callingCode: UInt
    ) {
        self.countryCode = countryCode
        self.callingCode = callingCode
    }
}

extension CountryCallingCode: Identifiable {
    public var id: String {
        countryCode
    }
}

extension CountryCallingCode: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CountryCallingCode: Decodable {
    private enum CodingKeys: String, CodingKey {
        case countryCode
        case callingCode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.countryCode = try container.decode(String.self, forKey: .countryCode)
        self.callingCode = try container.decode(UInt.self, forKey: .callingCode)
    }
}

public extension Array where Element == CountryCallingCode {
    var countryCodes: [String] {
        compactMap({ $0.countryCode })
    }
    
    func country(forCode code: String) -> Element? {
        first(where: { $0.countryCode.lowercased() == code.lowercased()})
    }
}

private extension String {
    var flagSymbol: String? {
        let base: UInt32 = 127397
        var result = ""
        for char in self.unicodeScalars {
            if let flagScalar = UnicodeScalar(base + char.value) {
                result.unicodeScalars.append(flagScalar)
            }
        }
        return result.isEmpty ? nil : String(result)
    }
}
