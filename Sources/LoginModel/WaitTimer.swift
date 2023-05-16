//
//  File.swift
//  
//
//  Created by Uwe Tilemann on 11.05.23.
//

import Foundation
import Combine

/// A 'WaitTimer' can be started or stopped. On start startTime and endTime will be set. When the timer is stopped (manually or the timer finished the endTime is set.
public class WaitTimer: ObservableObject {
    @Published public var isRunning: Bool = false
    
    let publisher: Timer.TimerPublisher
    var waitCancellable: Cancellable?
    @Published public var startTime: Date?
    @Published public var endTime: Date?

    init(interval: TimeInterval = 1.0) {
        self.publisher = Timer.publish(every: interval, tolerance: 0.5, on: .main, in: .default)
    }
    public func start() {
        isRunning = true
        
        startTime = .now
        endTime = nil

        waitCancellable = self.publisher
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.stop()
            })
    }

    public func stop() {
        waitCancellable = nil
        isRunning = false
        endTime = .now
    }
}
