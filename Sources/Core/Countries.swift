//
//  Countries.swift
//  Country Picker
//
//  Created by Uwe Tilemann on 07.03.24.
//

import Foundation

public struct Country: Decodable {
    public static var all: [Country] = loadJSON("Countries")
    public static var germany: Country = Country(code: "DE", label: "Germany", callingCode: 49)
    
    public let code: String
    public let label: String
    public let callingCode: UInt
    public let states: [State]?

    public struct State: Decodable {
        public let code: String
        public let label: String
    }
    
    public init(code: String, label: String, callingCode: UInt, states: [State]? = nil) {
        self.code = code
        self.label = label
        self.callingCode = callingCode
        self.states = states
    }
    
    public var flagSymbol: String? {
        code.flagSymbol
    }
}

extension Country: Identifiable {
    public var id: String {
        code
    }
}

extension Country.State: Identifiable {
    public var id: String {
        code
    }
}

extension Country: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension Country.State: Hashable {
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
