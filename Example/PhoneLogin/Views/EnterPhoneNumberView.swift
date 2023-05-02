//
//  EnterPhoneNumberView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import SwiftUI
//import SnabblePhoneAuth

struct DebugView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    @State private var userInfo: [String: Any] = [:]
    @State private var errorCode = false
    @State private var errorLogin = false

    var body: some View {
        VStack {
            Toggle(isOn: $errorCode) {
                Text("Test error on request code")
            }
            .onChange(of: errorCode) { _ in
                updateUserInfo()
            }
            Toggle(isOn: $errorLogin) {
                Text("Test error on login")
            }
            .onChange(of: errorLogin) { _ in
                updateUserInfo()
            }
       }
        .onAppear {
            if let error = loginModel.userInfo["error"] as? FakeEndpointError, error == .phoneNumberError {
                errorCode = true
            }
            if let error = loginModel.userInfo["error"] as? FakeEndpointError, error == .loginError {
                errorLogin = true
            }
        }
    }
    
    private func updateUserInfo() {
        userInfo = [:]
        if errorCode {
            userInfo["error"] = FakeEndpointError.phoneNumberError
        } else if errorLogin {
            userInfo["error"] = FakeEndpointError.loginError
        }
        if loginModel.state == .error, userInfo.isEmpty {
            loginModel.userInfo = userInfo
            loginModel.reset()
        }
        if !userInfo.isEmpty {
            loginModel.userInfo = userInfo
        }
        if !loginModel.userInfo.isEmpty, userInfo.isEmpty {
            loginModel.userInfo = userInfo
        }
    }
}

struct EnterPhoneNumberView: View {
    @State private var phoneNumber = ""
    @State private var isShowingDetailView = false
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    var body: some View {
        VStack {
            NavigationLink(destination: EnterCodeView(phoneNumber: phoneNumber), isActive: $isShowingDetailView) { EmptyView() }
            
            Form {
                Section(
                    content: {
                        HStack{
                            Text(loginModel.countryCode)
                            TextField("Handynummer", text: $phoneNumber)
                                .keyboardType(.phonePad)
                        }
                        
                        Button(action: {
                            isShowingDetailView = true
                            loginModel.sendPhoneNumber(phoneNumber)
                        }) {
                            Text("Code anfordern")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(AccentButtonStyle())
                        
                    },
                    header: {
                        Text("Zum Aktivieren des Logins, gib deine Handynummber ein.\nAnschließend erhälst du eine SMS mit einem Aktivierungscode.")
                            .multilineTextAlignment(.center)
                    }
                )
                .textCase(nil)
            }
            //DebugView()
        }
        .padding()
        .navigationTitle("Telefon-Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}

