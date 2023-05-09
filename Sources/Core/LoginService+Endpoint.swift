//
//  File.swift
//  
//
//  Created by Uwe Tilemann on 03.05.23.
//

import Foundation
import Combine

public extension Endpoint where Kind == EndpointKinds.Public, Response == PhoneResponse {
     static func send(phoneNumber: String) -> Self {
        let code = Int.random(in: 1000..<9999)
        
        return Endpoint(path: "delay/2", queryItems: [
            URLQueryItem(name: "phoneNumber", value: phoneNumber.replacingOccurrences(of: "+", with: "00")),
            URLQueryItem(name: "code", value: "\(code)")
        ])
    }
}

public extension Endpoint where Kind == EndpointKinds.Public, Response == Login {
    static func loginWith(code: String) -> Self {
        return Endpoint(path: "delay/2", queryItems: [
            URLQueryItem(name: "code", value: code)
        ])
    }
}

public struct PhoneResponse: Decodable {
    public let phoneNumber: String
    public let code: String
    public var timestamp = Date.now
}

public struct Login: Decodable {
    public let code: String
}
