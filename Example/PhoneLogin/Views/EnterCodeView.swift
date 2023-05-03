//
//  EnterCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import SwiftUI

struct EnterCodeView: View {
    var phoneNumber: String
    @State private var pinCode = ""
    @State private var codeValid = false
    @State private var canSend = false

    @EnvironmentObject var loginModel: PhoneLoginModel
    @State private var serverHint: String = ""
    @State private var errorMessage: String = ""

    @ViewBuilder
    var spinner: some View {
        if loginModel.state == .sendCode {
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
            if !serverHint.isEmpty {
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
                Text("\(loginModel.phoneNumber) gesendet.")
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
                            TextField("Pin-Code", text: $pinCode)
                                .keyboardType(.decimalPad)
                            
                            Button(action: {
                                print("login with code: \(pinCode)")
                                loginModel.loginWithCode(pinCode)
                            }) {
                                HStack {
                                    Text("Anmelden")
                                        .fontWeight(.bold)
                                        .opacity(canSend ? 1.0 : 0.5)
                                    spinner
                                }
                            }
                            .disabled(!canSend)
                            .buttonStyle(AccentButtonStyle())
                            Button(action: {
                                print("request code for \(loginModel.phoneNumber)")
                                loginModel.sendPhoneNumber(loginModel.phoneNumber)
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Code erneut anfordern")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                            }
                            
                        }
                    
                )
                .textCase(nil)

            }
            .onChange(of: loginModel.isLoggingIn) { newLogin in
                if newLogin {
                    errorMessage = ""
                    serverHint = "Du bist angemeldet!"
                }
            }
            .onChange(of: loginModel.receivedCode) { newCode in
                serverHint = "Server hat folgenden Code geschickt: \"\(newCode)\""
            }
            .onChange(of: loginModel.canLogin) { _ in
                canSend = self.canLogin
            }
            .onChange(of: pinCode) { newCode in
                canSend = self.canLogin
            }
            //DebugView()
            Spacer()
        }
        .padding()
        .navigationTitle("Code eingeben")
    }
        
    var canLogin: Bool {
        if pinCode.lengthOfBytes(using: .utf8) == 4 {
            return loginModel.canLogin
        }
        return false
    }
}

