//
//  EnterCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import SwiftUI
import SnabblePhoneAuth

public extension PhoneLoginModel {
    @ViewBuilder
    var messageView: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .foregroundColor(.red)
        }
    }
}

public struct EnterCodeView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    @FocusState private var enterCode

    @ViewBuilder
    var header: some View {
        HStack {
            Spacer()
            Text("Wir haben dir einen Code an\n\(loginModel.phoneNumberPrettyPrint) gesendet.\nBitte gib den Code ein.\n")
            .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    header: header,
                    footer: loginModel.messageView,
                    content: {
                            VStack {
                                TextField("Pin-Code", text: $loginModel.pinCode)
                                    .keyboardType(.decimalPad)
                                    .focused($enterCode)
                                
                                Button(action: {
                                    print("login with code: \(loginModel.pinCode)")
                                    loginModel.loginWithCode(loginModel.pinCode)
                                }) {
                                    HStack {
                                        Spacer(minLength: 0)
                                        HStack {
                                            Text("Anmelden")
                                                .fontWeight(.bold)
                                                .opacity(loginModel.canLogin ? 1.0 : 0.5)
                                            
                                            loginModel.progressView
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }
                                .buttonStyle(AccentButtonStyle(disabled: !loginModel.canLogin))
                                
                                RequestCodeButton(firstStep: false)
                            }
                        }
                    
                )
                .textCase(nil)
            }
            DebugView()
        }
        .onAppear {
            UserDefaults.pageVisited = .loginPage

            if loginModel.state == .waitingForCode {
                enterCode = true
                loginModel.startTimer()
            }
        }
       .padding()
        .navigationTitle("Code eingeben")
    }
}
