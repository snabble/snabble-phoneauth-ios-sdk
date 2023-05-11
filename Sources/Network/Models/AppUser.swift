//
//  AppUser.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-02.
//

import Foundation

public struct AppUser: Codable {
    public let id: String
    public let secret: String

    enum CodingKeys: String, CodingKey {
        case id = "userID"
        case secret
    }
    
    public init(id: String, secret: String) {
        self.id = id
        self.secret = secret
    }
}
