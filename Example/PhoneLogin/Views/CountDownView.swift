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
    
    init(from: Date, to: Date? = nil, completion: @escaping (() -> Void) = {}) {
        self.from = from
        self.to = to ?? (from + 30)
        self.handler = completion
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 20)) { _ in
            Canvas { context, size in
                let interval = to.timeIntervalSinceReferenceDate - from.timeIntervalSinceReferenceDate
                let width = size.width / interval * to.timeIntervalSinceNow
                
                if Date.now > to {
                    self.handler()
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
        .buttonStyle(RequestButtonStyle(firstStep: false, disabled: true, show: .constant(true), sendDate: .constant(.now)))
    }
}
