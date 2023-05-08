//
//  PhoneEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation

extension Endpoints {
    public enum Phone {
        public static func auth(metadata: Metadata, phoneNumber: String, userId: String) -> Endpoint<Void> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "userID": userId,
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(metadata.appId)/phone/auth",
                method: .post(data, nil),
                environment: metadata.environment
            )
        }

        public static func login(metadata: Metadata, phoneNumber: String, OTP: String) -> Endpoint<SnabbleNetwork.AppUser?> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "otp": OTP,
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(metadata.appId)/phone/login",
                method: .post(data, nil),
                environment: metadata.environment
            )
        }

        public static func delete(metadata: Metadata, phoneNumber: String) -> Endpoint<Void> {
            let data = try! JSONSerialization.data(withJSONObject: [
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(metadata.appId)/phone/users",
                method: .delete(data),
                environment: metadata.environment
            )
        }
    }
}
