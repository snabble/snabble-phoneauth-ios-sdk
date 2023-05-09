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
        } else {
            if !receivedCode.isEmpty {
                Text("Server hat folgenden Code geschickt \"\(receivedCode)\"")
                    .foregroundColor(.green)
            }
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
            VStack {
                Text("Wir haben dir einen Code an")
                Text("\(loginModel.phoneNumberPrettyPrint) gesendet.")
                Text("Bitte gib den Code ein.\n")
            }
            .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    public var body: some View {
        VStack {
            Form {
                Section(
                    header: header,
                    footer: loginModel.messageView,
                    content:
                        {
                            VStack {
                                TextField("Pin-Code", text: $loginModel.pinCode)
                                    .keyboardType(.decimalPad)
                                    .focused($enterCode)
                                
                                Button(action: {
                                    print("login with code: \(loginModel.pinCode)")
                                    loginModel.loginWithCode(loginModel.pinCode)
                                }) {
                                    HStack {
                                        Text("Anmelden")
                                            .fontWeight(.bold)
                                            .opacity(loginModel.canLogin ? 1.0 : 0.5)
                                        
                                        loginModel.progressView
                                    }
                                }
                                .buttonStyle(AccentButtonStyle(disabled: !loginModel.canLogin))
                                
                                RequestCodeButton(firstStep: false)
                            }
                        }
                    
                )
                .textCase(nil)
            }
            .onAppear {
                if !loginModel.receivedCode.isEmpty {
                    enterCode = true
                }
            }
            DebugView(debugConfig: .logs)
        }
        .padding()
        .navigationTitle("Code eingeben")
    }
}

