//
//  CountDownView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 04.04.23.
//

import SwiftUI

public struct CountDownButtonBackground: View {
    let from: Date
    let to: Date
    let handler: () -> Void
    
    init(interval: Double = 30, from: Date? = nil, to: Date? = nil, completion: @escaping (() -> Void) = {}) {
        self.from = from ?? .now
        self.to = to ?? (self.from + interval)
        self.handler = completion
    }

    public var body: some View {
        TimelineView(.periodic(from: self.from, by: 1 / 20)) { timeContext in
            Canvas { context, size in
                let interval = to.timeIntervalSinceReferenceDate - from.timeIntervalSinceReferenceDate
                let width = size.width / interval * to.timeIntervalSinceNow
                
                if timeContext.date > self.to {
                    DispatchQueue.main.async {
                        self.handler()
                    }
                }
                
                let fdRect = Rectangle().path(in: CGRect(x: 0, y: 0, width: width, height: size.height))
                context.fill(fdRect, with: .color(Color.accentColor))
            }
        }
    }
}

struct CountDownView_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {
            print("button action")
        }) {
                    Text("Code erneut anfordern")
                        .fontWeight(.bold)
                        .padding([.leading, .trailing])
        }
        .buttonStyle(RequestButtonStyle(firstStep: false, disabled: true, show: .constant(true), interval: 10))
    }
}
