//
//  File.swift
//  
//
//  Created by Uwe Tilemann on 02.05.23.
//

import Foundation
import Combine

public enum FakeEndpointError: Error {
    case phoneNumberError
    case loginError
}

extension FakeEndpointError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .phoneNumberError:
            return NSLocalizedString("Error: PhoneNumber endpoint failed.", comment: "")
        case .loginError:
            return NSLocalizedString("Error: Login endpoint failed.", comment: "")
        }
    }
}

open class LoginService: ObservableObject {
    private let session: URLSession
    
    public var userInfo: [String: Any] = [:]
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func send(phoneNumber: String) -> AnyPublisher<PhoneResponse, Error> {
        if let error = userInfo["error"] as? FakeEndpointError, error == .phoneNumberError {
            return session.publisher(for: .send(phoneNumber: phoneNumber), userInfo: userInfo)
        } else {
            return session.publisher(for: .send(phoneNumber: phoneNumber))
        }
    }
    
    public func loginWith(code: String) -> AnyPublisher<Login, Error> {
        if let error = userInfo["error"] as? FakeEndpointError, error == .loginError {
            return session.publisher(for: .loginWith(code: code), userInfo: userInfo)
        } else {
            return session.publisher(for: .loginWith(code: code))
        }
    }
}
