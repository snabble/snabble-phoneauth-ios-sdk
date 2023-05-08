//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-02.
//

import Foundation

public struct Token: Codable {
    public let id: String
    public let value: String
    public let issuedAt: Date
    public let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case value = "token"
        case issuedAt
        case expiresAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.value = try container.decode(String.self, forKey: .value)
        self.issuedAt = try container.decode(Date.self, forKey: .issuedAt)
        self.expiresAt = try container.decode(Date.self, forKey: .expiresAt)
    }

    public enum Scope: String {
        case retailerApp
        case paymentSystem
        case pointOfSale
        case gatekeeper
    }

    func isValid() -> Bool {
        expiresAt.timeIntervalSinceNow.sign == .plus
    }
}
