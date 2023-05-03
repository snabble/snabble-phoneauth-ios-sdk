//
//  CountDownView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 04.04.23.
//

import SwiftUI

struct CountDownView: View {
    let from: Date
    let to: Date
    let height: CGFloat
    let handler: () -> Void
    
    init(from: Date, to: Date, height: CGFloat = 4.0, completion: @escaping (() -> Void) = {}) {
        self.from = from
        self.to = to
        self.height = height
        self.handler = completion
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 20)) { _ in
            Canvas { context, size in
                let interval = to.timeIntervalSinceReferenceDate - from.timeIntervalSinceReferenceDate
                let width = size.width / interval * to.timeIntervalSinceNow
                
                if Date.now > to {
                    self.handler()
                }
                let bgRect = Capsule().path(in: CGRect(x: 0, y: (size.height / 2) / 2, width: size.width, height: size.height / 2))
                context.fill(bgRect, with: .color(.secondary))
                
                let fdRect = Capsule().path(in: CGRect(x: 0, y: 0, width: width, height: size.height))
                context.fill(fdRect, with: .color(.primary))
            }
        }
        .frame(height: height)
    }
}

struct CountDownView_Previews: PreviewProvider {
    static var previews: some View {
        CountDownView(from: .now, to: .now + 10.0)
    }
}
