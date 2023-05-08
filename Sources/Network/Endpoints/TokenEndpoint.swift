//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import OneTimePassword

extension Endpoints {
    enum Token {
        static func get(
            metadata: Metadata,
            appUser: SnabbleNetwork.AppUser,
            projectId: String,
            role: SnabbleNetwork.Token.Scope = .retailerApp,
            onEnvironment environment: Environment = .production
        ) -> Endpoint<SnabbleNetwork.Token> {
            var endpoint: Endpoint<SnabbleNetwork.Token> =  .init(path: "/tokens",
                                                                  method: .get([
                                                                    .init(name: "project", value: projectId),
                                                                    .init(name: "role", value: role.rawValue)
                                                                  ]),
                                                                  environment: environment)
            if let authorization = authorization(withMetadata: metadata, appUser: appUser) {
                endpoint.headerFields = ["Authorization": "Basic \(authorization)"]
            }
            return endpoint
        }

        private static func authorization(withMetadata metadata: Metadata, appUser: SnabbleNetwork.AppUser) -> String? {
            guard let password = password(withSecret: metadata.appSecret, forDate: Date()) else { return nil }
            return "\(metadata.appId):\(password):\(appUser.id):\(appUser.secret)".data(using: .utf8)?.base64EncodedString()
        }

        private static func password(withSecret secret: String, forDate date: Date) -> String? {
            guard
                let secretData = NSData(base32String: secret) as? Data,
                let generator = try? Generator(
                    factor: .timer(period: 30),
                    secret: secretData,
                    algorithm: .sha256,
                    digits: 8
                )
            else {
                return nil
            }

            let token = OneTimePassword.Token(name: "", issuer: "", generator: generator)
            do {
                return try token.generator.password(at: date)
            } catch {
                return nil
            }
        }
    }
}
