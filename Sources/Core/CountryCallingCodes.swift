//
//  CountryCallingCodes.swift
//  
//
//  Created by Uwe Tilemann on 04.05.23.
//

import Foundation

public struct CountryCallingCode: Identifiable, Hashable {
    public var id: String {
        return countryCode
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let countryCode: String // eg. DE, AT, CH
    public let callingCode: String // eg. 49
    public let internationalCode: String // eg. 00
    public let trunkPrefix: String // eg. 0 (see https://en.wikipedia.org/wiki/Trunk_prefix)
    
    public init(countryCode: String, callingCode: String, internationalCode: String = "00", trunkPrefix: String = "0") {
        self.countryCode = countryCode
        self.callingCode = callingCode
        self.internationalCode = internationalCode
        self.trunkPrefix = trunkPrefix
    }
    public func numberRemovingTrunk(_ string: String) -> String {
        guard !trunkPrefix.isEmpty, string.hasPrefix(trunkPrefix) else {
            return string
        }
        let start = string.index(string.startIndex, offsetBy: trunkPrefix.count)
        
        return String(string[start...])
    }
    
    public func dialString(_ string: String) -> String {
        let number = numberRemovingTrunk(string).replacingOccurrences(of: " ", with: "")
        return "+\(callingCode)\(number)" 
    }
    
    public func prettyPrint(_ string: String) -> String {
        let number = numberRemovingTrunk(string)
        
        return "+\(callingCode) \(number)"
    }
    public var countryName: String {
        return Locale.current.localizedString(forRegionCode: countryCode) ?? "n/a"
    }
}

extension CountryCallingCode: Decodable {
    private enum CodingKeys: String, CodingKey {
        case countryCode
        case callingCode
        case trunkPrefix
        case internationalCode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.countryCode = try container.decode(String.self, forKey: .countryCode)
        self.callingCode = try container.decode(String.self, forKey: .callingCode)
        if let prefix = try container.decodeIfPresent(String.self, forKey: .trunkPrefix) {
            self.trunkPrefix = prefix
        } else {
            self.trunkPrefix = ""
        }
        if let intCode = try container.decodeIfPresent(String.self, forKey: .internationalCode) {
            self.internationalCode = intCode
        } else {
            self.internationalCode = "00"
        }
    }
}

public protocol CountryProviding: AnyObject {
    /// Providing `CountryProviding` `
    /// - Returns: The array of supported `CountryCallingCode`  or `nil`
    func supportedCountries() -> [CountryCallingCode]?
    var selectedCountry: String? { get set }
}

public enum CountryProvider {
    /// List of supported country codes
    /// see: https://en.wikipedia.org/wiki/Telephone_numbers_in_Europe
    ///
    public static let defaultCountries: [CountryCallingCode] = [
        CountryCallingCode(countryCode: "AT", callingCode: "43"),
        CountryCallingCode(countryCode: "CH", callingCode: "41"),
        CountryCallingCode(countryCode: "DE", callingCode: "49")
    ]

    /// Reference to the implementation of the `CountryProviding` implementation
    public static weak var provider: CountryProviding?

    public static var countries: [CountryCallingCode] {
        if let countries = provider?.supportedCountries(), !countries.isEmpty {
            return countries
        }
        return defaultCountries
    }
}

public enum CountryCallingCodes {
    public static let defaultCountry = CountryCallingCode(countryCode: "DE", callingCode: "49")
    
    public static var countries: [CountryCallingCode] {
        return CountryProvider.countries
    }
    public static var countryNames: [String] {
        return countries.compactMap({ $0.countryCode })
    }
    public static func country(for code: String) -> CountryCallingCode? {
        return countries.first(where: { $0.countryCode == code})
    }
}

extension String {
    public var countryFlagSymbol: String? {
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
