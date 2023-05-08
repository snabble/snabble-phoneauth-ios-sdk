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
        static func post(app: App, projectId: String? = nil) -> Endpoint<AppUserResponse> {
            var queryItems: [URLQueryItem]?
            if let projectId = projectId {
                queryItems = [.init(name: "project", value: projectId)]
            }
            var endpoint: Endpoint<AppUserResponse> = .init(
                path: "/apps/\(app.id)/users",
                method: .post(nil, queryItems),
                environment: app.environment
            )
            if let authorization = authorization(withApp: app) {
                endpoint.headerFields = ["Authorization": "Basic \(authorization)"]
            }
            return endpoint
        }

        private static func authorization(withApp app: App) -> String? {
            guard let password = password(withSecret: app.secret, forDate: Date()) else { return nil }
            return "\(app.id):\(password)".data(using: .utf8)?.base64EncodedString()
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
