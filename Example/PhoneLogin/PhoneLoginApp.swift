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
    let loginModel = PhoneLoginModel(stateMachine: StateMachine(state: .start), loginService: LoginService(session: .shared))

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(loginModel)
        }
    }
}
