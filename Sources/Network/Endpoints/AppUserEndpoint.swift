//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import SwiftOTP

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
                let secretData = base32DecodeToData(secret),
                let totp = TOTP(secret: secretData, digits: 8, timeInterval: 30, algorithm: .sha256)
            else {
                return nil
            }
            return totp.generate(time: date)
        }
    }
}

struct UsersResponse: Codable {
    let appUser: AppUser
    let token: Token?
}
