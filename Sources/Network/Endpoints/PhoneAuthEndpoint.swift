//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation

extension Endpoints {
    enum Phone {
        static func auth(app: App, phoneNumber: String, userId: String) -> Endpoint<Void> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "userID": userId,
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(app.id)/phone/auth",
                method: .post(data, nil),
                environment: app.environment
            )
        }

        static func login(app: App, phoneNumber: String, OTP: String) -> Endpoint<AppUser?> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "otp": OTP,
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(app.id)/phone/login",
                method: .post(data, nil),
                environment: app.environment
            )
        }

        static func delete(app: App, phoneNumber: String) -> Endpoint<Void> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(app.id)/phone/users",
                method: .delete(data),
                environment: app.environment
            )
        }
    }
}
