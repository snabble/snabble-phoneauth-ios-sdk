//
//  Utilities.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import SwiftUI

public struct AccentButtonStyle: ButtonStyle {
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.top, .bottom], 15)
            .padding([.leading, .trailing], 20)
            .frame(width: 300)
            .background(Color("AccentColor"))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

public struct RequestButtonStyle: ButtonStyle {
    var firstStep: Bool
    var disabled: Bool
    @Binding var show: Bool
    var sendDate: Date = .now
    
    public init(firstStep: Bool = true, disabled: Bool, show: Binding<Bool>) {
        self.firstStep = firstStep
        self.disabled = disabled
        self._show = show
    }

    @ViewBuilder
    var background: some View {
        if !firstStep, show {
            CountDownButtonBackground(from: sendDate, to: sendDate + 30) {
                DispatchQueue.main.async {
                    self.show = false
                }
            }
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        if firstStep {
            configuration.label
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], 20)
                .frame(width: 300)
                .background(Color("AccentColor"))
                .foregroundColor(.white.opacity(disabled ? 0.5 : 1.0))
                .disabled(disabled)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            configuration.label
                .padding([.top, .bottom], 10)
                .background(background)
                .foregroundColor(Color("ButtonColor"))
                .opacity(disabled ? 0.5 : 1.0)
                .disabled(disabled)
                .clipShape(Capsule())
        }
    }

}
