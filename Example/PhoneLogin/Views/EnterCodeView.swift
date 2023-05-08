//
//  EnterCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import SwiftUI
import SnabblePhoneAuth

struct EnterCodeView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    @FocusState private var enterCode

    @ViewBuilder
    var loginSpinner: some View {
        if  loginModel.state == .sendCode {
            ProgressView()
               .padding([.leading], 10)
        }
    }
        
    @ViewBuilder
    var message: some View {
        if !loginModel.errorMessage.isEmpty {
            Text(loginModel.errorMessage)
                .foregroundColor(.red)
        } else {
            if !loginModel.receivedCode.isEmpty {
                Text("Server hat folgenden Code geschickt \"\(loginModel.receivedCode)\"")
                    .foregroundColor(.green)
            }
        }
    }

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
    
    var body: some View {
        VStack {
            Form {
                Section(
                    header: header,
                    footer: message,
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
                                        loginSpinner
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
            //DebugView()
            Spacer()
        }
        .padding()
        .navigationTitle("Code eingeben")
    }
}

