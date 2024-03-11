//
//  Countries.swift
//  Country Picker
//
//  Created by Uwe Tilemann on 07.03.24.
//

import Foundation

public struct Country {
    public let code: String
    public let label: String
    public var callingCode: UInt?
    
    public var flagSymbol: String? {
        code.flagSymbol
    }
    public init(code: String, label: String, callingCode: UInt? = nil) {
        self.code = code
        self.label = label
        self.callingCode = callingCode
    }
}

public struct Countries {
    public static var `default`: Countries = loadJSON("Countries")
    
    public let countries: [Country]
    public let subdivisions: [String: [Country]]
    
    public init(
        countries: [Country],
        subdivisions: [String: [Country]]
    ) {
        self.countries = countries
        self.subdivisions = subdivisions
    }
}

extension Countries: Decodable {
    private enum CodingKeys: String, CodingKey {
        case countries
        case subdivisions
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.countries = try container.decode([Country].self, forKey: .countries)
        self.subdivisions = try container.decode([String: [Country]].self, forKey: .subdivisions)
    }
}

extension Country: Decodable {
    private enum CodingKeys: String, CodingKey {
        case code
        case label
        case callingCode
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        self.label = try container.decode(String.self, forKey: .label)
        self.callingCode = try container.decodeIfPresent(UInt.self, forKey: .callingCode)
   }
}

extension Country: Identifiable {
    public var id: String {
        code
    }
}

extension Country: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension Array where Element == Country {
    var countryCodes: [String] {
        compactMap({ $0.code })
    }
    
    func country(forCode code: String) -> Element? {
        first(where: { $0.code.lowercased() == code.lowercased()})
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
