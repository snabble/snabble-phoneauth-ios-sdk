//
//  CountryCallingCodes.swift
//  
//
//  Created by Uwe Tilemann on 04.05.23.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let selectedCountry = "country"
    }

    public class var selectedCountry: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.selectedCountry)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.selectedCountry)
            UserDefaults.standard.synchronize()
        }
    }
}

public struct CountryCallingCode {
    public let countryCode: String // eg. DE, AT, CH
    public let callingCode: String // eg. 49
    public let internationalCode: String // eg. 00
    public let trunkPrefix: String // eg. 0 (see https://en.wikipedia.org/wiki/Trunk_prefix)
    public let indexSet: IndexSet?
    
    public init(countryCode: String, callingCode: String, indexSet: IndexSet? = nil, internationalCode: String = "00", trunkPrefix: String = "0") {
        self.countryCode = countryCode
        self.callingCode = callingCode
        self.indexSet = indexSet
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
        return "\(internationalCode)\(callingCode)\(numberRemovingTrunk(string))"
    }
    public func prettyPrint(_ string: String) -> String {
        let number = numberRemovingTrunk(string)
        
        return "+\(callingCode) \(number)"
    }
    public var countryName: String {
        return Locale.current.localizedString(forRegionCode: countryCode) ?? "n/a"
    }
}

public enum CountryCallingCodes {
    public static let info: [CountryCallingCode] = [
        CountryCallingCode(countryCode: "AT", callingCode: "43"),
        CountryCallingCode(countryCode: "BE", callingCode: "32"),
        CountryCallingCode(countryCode: "CH", callingCode: "41"),
        defaultCountry,
        CountryCallingCode(countryCode: "DK", callingCode: "45", trunkPrefix: ""),
        CountryCallingCode(countryCode: "ES", callingCode: "34", trunkPrefix: ""),
        CountryCallingCode(countryCode: "FR", callingCode: "33"),
        CountryCallingCode(countryCode: "GR", callingCode: "423", trunkPrefix: ""),
        CountryCallingCode(countryCode: "IT", callingCode: "39", trunkPrefix: ""),
        CountryCallingCode(countryCode: "NL", callingCode: "31"),
        CountryCallingCode(countryCode: "LU", callingCode: "352", trunkPrefix: ""),
        CountryCallingCode(countryCode: "LI", callingCode: "423", trunkPrefix: "")
    ]
    public static let defaultCountry = CountryCallingCode(countryCode: "DE", callingCode: "49")
    
    public static var countries: [String] {
        return info.compactMap({ $0.countryCode })
    }
    public static func country(for code: String) -> CountryCallingCode? {
        return info.first(where: { $0.countryCode == code})
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
