//
//  PhoneLoginApp.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 17.01.23.
//

import SwiftUI
import SnabblePhoneAuth

@main
struct PhoneLoginApp: App {
    let snabble = Snabble(configuration: .development)

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(snabble.loginManager)
        }
    }
}
