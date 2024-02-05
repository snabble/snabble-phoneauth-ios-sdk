//
//  PhoneAuthScreen.swift
//  PhoneAuthScreen
//
//  Created by Uwe Tilemann on 17.01.23.
//

import SwiftUI
import SnabblePhoneAuth

struct PhoneAuthScreen: View {
    let phoneAuth: PhoneAuth = PhoneAuth(configuration: .testing)

    var body: some View {
        NavigationView {
            Color.red
        }
    }
}

struct PhoneAuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAuthScreen()
    }
}
