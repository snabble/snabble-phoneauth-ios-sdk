//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import OneTimePassword

extension Endpoints {
    enum AppUser {
        static func post(configuration: Configuration, projectId: String? = nil) -> Endpoint<UsersResponse> {
            var queryItems: [URLQueryItem]?
            if let projectId = projectId {
                queryItems = [.init(name: "project", value: projectId)]
            }
            var endpoint: Endpoint<UsersResponse> = .init(
                path: "/apps/\(configuration.appId)/users",
                method: .post(nil, queryItems),
                configuration: configuration,
                parse: { data in
                    try Endpoints.jsonDecoder.decode(UsersResponse.self, from: data)
                }
            )
            if let authorization = authorization(withConfiguration: configuration) {
                endpoint.headerFields = ["Authorization": "Basic \(authorization)"]
            }
            return endpoint
        }

        private static func authorization(withConfiguration configuration: Configuration) -> String? {
            guard let password = password(withSecret: configuration.appSecret, forDate: Date()) else { return nil }
            return "\(configuration.appId):\(password)".data(using: .utf8)?.base64EncodedString()
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

struct UsersResponse: Codable {
    let appUser: AppUser
    let token: Token?
}
