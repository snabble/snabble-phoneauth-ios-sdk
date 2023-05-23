//
//  ActionLogger.swift
//  
//
//  Created by Uwe Tilemann on 08.05.23.
//

import Foundation
import Combine

/// The `LogAction` provides a simple model with an `action` and optional `info` `String` element.
struct LogAction: Identifiable, Hashable {
    let action: String
    let info: String
    var timeStamp = Date.now
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    init(action: String, info: String = "") {
        self.action = action
        self.info = info
    }
}

extension LogAction: CustomStringConvertible {
    var description: String {
        if !info.isEmpty {
            return "[\(action)] > \(info)"
        } else {
            return "[\(action)]"
        }
    }
}

/// The `ActionLogger` provides a simple model to collect and reset an array of `LogAction` elements.
class ActionLogger: ObservableObject {
    
    ///
    /// Can be used to update an observer.
    ///
    /// ```Swift
    /// .onChange(ActionLogger.shared.logs) {
    /// }
    /// ```
    ///
    @Published var logs: [LogAction] = []
    
    /// Add a `LogAction`element
    func add(log: LogAction) {
        print(log.description)
        logs.append(log)
    }
    /// Reset the `logs` array
    func reset() {
        logs = []
    }
}

extension ActionLogger {
    /// A shared instance of the ActionLogger
    static var shared = ActionLogger()
}
