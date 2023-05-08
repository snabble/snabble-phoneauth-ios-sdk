//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation

extension Endpoints {
    enum PhoneAuth {
        static func start(app: App, phoneNumber: String, userId: String) -> Endpoint<Void> {
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
    }
}
