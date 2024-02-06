//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import SwiftOTP

extension Endpoints {
    enum Token {
        static func get(
            configuration: Configuration,
            appUser: SnabbleNetwork.AppUser,
            projectId: String,
            role: SnabbleNetwork.Token.Scope = .retailerApp
        ) -> Endpoint<SnabbleNetwork.Token> {

            var endpoint: Endpoint<SnabbleNetwork.Token> = .init(path: "/tokens",
                                                                 method: .get([
                                                                    .init(name: "project", value: projectId),
                                                                    .init(name: "role", value: role.rawValue)
                                                                 ]),
                                                                 configuration: configuration,
                                                                 parse: { data in
                try Endpoints.jsonDecoder.decode(SnabbleNetwork.Token.self, from: data)
            })
            if let authorization = authorization(withConfiguration: configuration, appUser: appUser) {
                endpoint.headerFields = ["Authorization": "Basic \(authorization)"]
            }
            return endpoint
        }

        private static func authorization(withConfiguration configuration: Configuration, appUser: SnabbleNetwork.AppUser) -> String? {
            guard let password = password(withSecret: configuration.appSecret, forDate: Date()) else { return nil }
            return "\(configuration.appId):\(password):\(appUser.id):\(appUser.secret)".data(using: .utf8)?.base64EncodedString()
        }

        private static func password(withSecret secret: String, forDate date: Date) -> String? {
            guard
                let secretData = base32DecodeToData(secret),
                let totp = TOTP(secret: secretData, digits: 8, timeInterval: 30, algorithm: .sha256)
            else {
                return nil
            }
            return totp.generate(time: date)
        }
    }
}
