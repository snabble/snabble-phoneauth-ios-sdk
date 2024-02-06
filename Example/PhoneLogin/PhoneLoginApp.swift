//
//  PhoneLoginApp.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 17.01.23.
//

import SwiftUI
import SnabblePhoneAuth
import SnabbleNetwork

@main
struct PhoneLoginApp: App {
    let phoneAuth = SnabblePhoneAuth.PhoneAuth(configuration: .testing)
    
    let test = SnabbleNetwork.HTTPError.invalidResponse(.forbidden)
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
