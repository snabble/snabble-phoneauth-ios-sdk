//
//  DebugView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 03.05.23.
//

import Foundation
import SwiftUI
import SnabblePhoneAuth

struct DebugView: View {
//    @EnvironmentObject var loginModel: PhoneLoginModel
//    @State private var userInfo: [String: Any] = [:]
//    @State private var errorCode = false
//    @State private var errorLogin = false
//
    var body: some View {
        VStack {
            
        }
//        VStack {
//            Toggle(isOn: $errorCode) {
//                Text("Test error on request code")
//            }
//            .onChange(of: errorCode) { _ in
//                updateUserInfo()
//            }
//            Toggle(isOn: $errorLogin) {
//                Text("Test error on login")
//            }
//            .onChange(of: errorLogin) { _ in
//                updateUserInfo()
//            }
//       }
//        .onAppear {
//            if let error = loginModel.userInfo["error"] as? FakeEndpointError, error == .phoneNumberError {
//                errorCode = true
//            }
//            if let error = loginModel.userInfo["error"] as? FakeEndpointError, error == .loginError {
//                errorLogin = true
//            }
//        }
    }
//
//    private func updateUserInfo() {
//        userInfo = [:]
//        if errorCode {
//            userInfo["error"] = FakeEndpointError.phoneNumberError
//        } else if errorLogin {
//            userInfo["error"] = FakeEndpointError.loginError
//        }
//        if loginModel.state == .error, userInfo.isEmpty {
//            loginModel.userInfo = userInfo
//            loginModel.reset()
//        }
//        if !userInfo.isEmpty {
//            loginModel.userInfo = userInfo
//        }
//        if !loginModel.userInfo.isEmpty, userInfo.isEmpty {
//            loginModel.userInfo = userInfo
//        }
//    }
}

