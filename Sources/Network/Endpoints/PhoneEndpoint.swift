//
//  PhoneEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation
import SnabbleModels

extension Endpoints {
    public enum Phone {
        public static func auth(configuration: Configuration, phoneNumber: String) -> Endpoint<Void> {
            // swiftlint:disable:next force_try
            let data = try! JSONSerialization.data(withJSONObject: [
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(configuration.appId)/verification/sms",
                method: .post(data, nil),
                configuration: configuration,
                parse: { _ in
                    return ()
                }
            )
        }

        public static func login(configuration: Configuration, phoneNumber: String, OTP: String) -> Endpoint<SnabbleModels.AppUser?> {
            // swiftlint:disable:next force_try
            let data = try! JSONSerialization.data(withJSONObject: [
                "otp": OTP,
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(configuration.appId)/verification/sms/otp",
                method: .post(data, nil),
                configuration: configuration,
                parse: { data in
                    do {
                        return try Endpoints.jsonDecoder.decode(SnabbleModels.AppUser.self, from: data)
                    } catch {
                        if case DecodingError.keyNotFound(let codingKey, _) = error {
                            if codingKey.stringValue == "secret" {
                                return nil
                            }
                        }
                        if data.isEmpty {
                            return nil
                        }
                        throw error
                    }
                })
        }

        public static func delete(configuration: Configuration, phoneNumber: String) -> Endpoint<Void> {
            // swiftlint:disable:next force_try
            let data = try! JSONSerialization.data(withJSONObject: [
                "phoneNumber": phoneNumber
            ])
            return .init(
                path: "/\(configuration.appId)/verification/sms/delete",
                method: .post(data, nil),
                configuration: configuration,
                parse: { _ in
                    return ()
                }
            )
        }
    }
}
