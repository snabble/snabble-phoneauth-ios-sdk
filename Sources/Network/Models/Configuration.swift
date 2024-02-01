//
//  Configuration.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation

public struct Configuration {
    public let appId: String
    public let appSecret: String
    public let environment: Environment
    public let projectId: String

    public init(appId: String, appSecret: String, environment: Environment, projectId: String) {
        self.appId = appId
        self.appSecret = appSecret
        self.environment = environment
        self.projectId = projectId
    }
}

extension Configuration: Equatable {}
