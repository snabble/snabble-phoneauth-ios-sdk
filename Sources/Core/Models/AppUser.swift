//
//  AppUser.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-02.
//

import Foundation
import SnabbleNetwork

public struct AppUser: Codable {
    public let id: String
    public let secret: String
}

extension AppUser {
    func toDTO() -> SnabbleNetwork.AppUser {
        SnabbleNetwork.AppUser(id: id, secret: secret)
    }
}

extension SnabbleNetwork.AppUser {
    func fromDTO() -> AppUser {
        AppUser(id: id, secret: secret)
    }
}
