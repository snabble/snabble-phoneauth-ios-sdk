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
            .padding([.leading, .trailing], 22)
            .frame(width: 320)
            .background(Color("AccentColor"))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

