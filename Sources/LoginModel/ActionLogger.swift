//
//  ActionLogger.swift
//  
//
//  Created by Uwe Tilemann on 08.05.23.
//

import Foundation
import Combine

/// The `LogAction` provides a simple model with an `action` and optional `info` `String` element.
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

/// The `ActionLogger` provides a simple model to collect and reset an array of `LogAction` elements.
public class ActionLogger: ObservableObject {
    
    ///
    /// Can be used to update an observer.
    ///
    /// ```Swift
    /// .onChange(ActionLogger.shared.logs) {
    /// }
    /// ```
    ///
    @Published public var logs: [LogAction] = []
    
    /// Add a `LogAction`element
    public func add(log: LogAction) {
        print(log.description)
        logs.append(log)
    }
    /// Reset the `logs` array
    public func reset() {
        logs = []
    }
}

extension ActionLogger {
    /// A shared instance of the ActionLogger
    public static var shared = ActionLogger()
}
