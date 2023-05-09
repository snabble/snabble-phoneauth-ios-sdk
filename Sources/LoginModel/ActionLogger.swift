//
//  ActionLogger.swift
//  
//
//  Created by Uwe Tilemann on 08.05.23.
//

import Foundation
import Combine

public struct LogAction: Identifiable, Hashable {
    public let action: String
    public let info: String
    public var timeStamp = Date.now
    public let id = UUID()
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public init(action: String, info: String = "") {
        self.action = action
        self.info = info
    }
}

extension LogAction: CustomStringConvertible {
    public var description: String {
        if !info.isEmpty {
            return "[\(action)] > \(info)"
        } else {
            return "[\(action)]"
        }
    }
}

public class ActionLogger: ObservableObject {
    
    @Published public var logs: [LogAction] = []
    
    public func add(log: LogAction) {
        print(log.description)
        logs.append(log)
    }
    public func reset() {
        logs = []
    }
}

extension ActionLogger {
    public static var shared = ActionLogger()
}
