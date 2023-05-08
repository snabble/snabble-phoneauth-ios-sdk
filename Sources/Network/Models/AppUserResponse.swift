//
//  AppUserToken.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-02.
//

import Foundation

struct AppUserResponse: Codable {
    let appUser: AppUser
    let token: Token?

//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.appUser = try container.decode(AppUser.self, forKey: .appUser)
//        self.token = try container.decodeIfPresent(Token.self, forKey: .token)
//    }
}
