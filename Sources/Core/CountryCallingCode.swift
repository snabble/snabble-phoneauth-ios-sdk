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
    public let callingCode: UInt // eg. 49
    public let internationalCode: UInt // eg. 00
    public let trunkPrefix: UInt? // eg. 0 (see https://en.wikipedia.org/wiki/Trunk_prefix)
    
    public var countryName: String {
        locale.localizedString(forRegionCode: countryCode) ?? "n/a"
    }
    
    public var flagSymbol: String? {
        countryCode.flagSymbol
    }
    
    public let locale: Locale
    
    public init(
        countryCode: String,
        callingCode: UInt,
        internationalCode: UInt = 00,
        trunkPrefix: UInt? = nil,
        
        locale: Locale = Locale.current
    ) {
        self.countryCode = countryCode
        self.callingCode = callingCode
        self.internationalCode = internationalCode
        self.trunkPrefix = trunkPrefix
        
        self.locale = locale
    }
    
    private func numberRemovingTrunk(_ string: String) -> String {
        guard let trunkPrefix, string.hasPrefix("\(trunkPrefix)") else {
            return string
        }
        let start = string.index(string.startIndex, offsetBy: "\(trunkPrefix)".count)
        return String(string[start...])
    }
    
    func internationalPhoneNumber(_ phoneNumber: String) -> String {
        let phoneNumber = numberRemovingTrunk(phoneNumber)
            .replacingOccurrences(of: " ", with: "")
        return "+\(callingCode)\(phoneNumber)"
    }
    
    public func prettyPrint(_ phoneNumber: String) -> String {
        let phoneNumber = numberRemovingTrunk(phoneNumber)
        return "+\(callingCode) \(phoneNumber)"
    }
}

extension CountryCallingCode: Identifiable, Hashable {
    public var id: String {
        countryCode
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
        self.callingCode = try container.decode(UInt.self, forKey: .callingCode)
        self.trunkPrefix = try container.decodeIfPresent(UInt.self, forKey: .trunkPrefix)
        self.internationalCode = try container.decodeIfPresent(UInt.self, forKey: .internationalCode) ?? 00
        self.locale = Locale.current
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
