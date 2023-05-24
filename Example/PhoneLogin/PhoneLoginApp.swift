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
    let loginModel = LoginModel()
    
    init() {
#if DEBUG
        UserDefaults.logActions = true
#else
        UserDefaults.logActions = false
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(loginModel.phoneModel)
        }
    }
}
