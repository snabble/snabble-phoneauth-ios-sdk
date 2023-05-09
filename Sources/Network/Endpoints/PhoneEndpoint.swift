//
//  PhoneEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation

extension Endpoints {
    public enum Phone {
        public static func auth(configuration: Configuration, phoneNumber: String) -> Endpoint<NoContent> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(configuration.appId)/phone/auth",
                method: .post(data, nil),
                configuration: configuration
            )
        }

        public static func login(configuration: Configuration, phoneNumber: String, OTP: String) -> Endpoint<SnabbleNetwork.AppUser?> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "otp": OTP,
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(configuration.appId)/phone/login",
                method: .post(data, nil),
                configuration: configuration
            )
        }

        public static func delete(configuration: Configuration, phoneNumber: String) -> Endpoint<NoContent> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(configuration.appId)/phone/users",
                method: .delete(data),
                configuration: configuration
            )
        }
    }
}

public struct NoContent: Decodable {}
