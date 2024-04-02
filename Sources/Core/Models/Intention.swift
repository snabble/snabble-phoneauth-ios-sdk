//
//  Intention.swift
//
//
//  Created by Andreas Osberghaus on 2024-04-02.
//

import Foundation
import SnabbleNetwork

public enum Intention {
    case signIn
    case changePhoneNumber
}

extension Intention {
    func toDTO() -> Endpoints.Phone.Intention {
        switch self {
        case .signIn:
            return .signIn
        case .changePhoneNumber:
            return .changePhoneNumber
        }
    }
}
