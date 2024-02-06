//
//  Configuration.swift
//  
//
//  Created by Andreas Osberghaus on 2023-05-03.
//

import Foundation
import SnabbleNetwork

public struct Configuration {
    public let appId: String
    public let appSecret: String
    public let domain: Domain
    public let projectId: String

    public init(appId: String, appSecret: String, domain: Domain, projectId: String) {
        self.appId = appId
        self.appSecret = appSecret
        self.domain = domain
        self.projectId = projectId
    }
}

extension Configuration: Equatable {}

extension Configuration {
    func toDTO() -> SnabbleNetwork.Configuration {
        SnabbleNetwork.Configuration(
            appId: appId,
            appSecret: appSecret,
            domain: domain.toDTO(),
            projectId: projectId
        )
    }
}

extension SnabbleNetwork.Configuration {
    func fromDTO() -> Configuration {
        Configuration(
            appId: appId,
            appSecret: appSecret,
            domain: domain.fromDTO(),
            projectId: projectId
        )
    }
}
