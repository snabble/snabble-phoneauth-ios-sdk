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
    let phoneAuth = PhoneAuth(configuration: .testing)
    
//    init() {
//#if DEBUG
//        UserDefaults.logActions = true
//#else
//        UserDefaults.logActions = false
//#endif
//    }

    var body: some Scene {
        WindowGroup {
            PhoneAuthScreen()
        }
    }
}
