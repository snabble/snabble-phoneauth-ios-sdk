//
//  EnterCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import SwiftUI
import SnabblePhoneAuth

struct EnterCodeView: View {
    var phoneNumber: String
    @State private var pinCode = ""
    @State private var codeValid = false
    @State private var canSend = false
    
    @EnvironmentObject var loginModel: PhoneLoginModel
    @State private var serverHint: String = ""
    @State private var errorMessage: String = ""
    @State private var sendDate: Date = .now
    
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
                Text("\(loginModel.phoneNumberPrettyPrint) gesendet.")
                Text("Bitte gib den Code ein.\n")
            }
            .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    @State private var showCountdown: Bool = true
    @State private var disabled: Bool = true

    var body: some View {
        VStack {
            Form {
                Section(
                    header: header,
                    footer: message,
                    content:
                        {
                            VStack {
                                TextField("Pin-Code", text: $pinCode)
                                    .keyboardType(.decimalPad)
                                    .focused($enterCode)
                                
                                Button(action: {
                                    print("login with code: \(pinCode)")
                                    loginModel.loginWithCode(pinCode)
                                }) {
                                    HStack {
                                        Text("Anmelden")
                                            .fontWeight(.bold)
                                            .opacity(canSend ? 1.0 : 0.5)
                                        loginSpinner
                                    }
                                }
                                .disabled(!canSend)
                                .buttonStyle(AccentButtonStyle())
                                
                                RequestCodeButton(firstStep: false)
                            }
                        }
                    
                )
                .textCase(nil)
            }
            .onAppear {
                if !loginModel.receivedCode.isEmpty {
                    print("receivedCode: \(loginModel.receivedCode)")
                    withAnimation {
                        serverHint = "Server hat folgenden Code geschickt: \"\(loginModel.receivedCode)\""
                    }
                }
            }
            .onChange(of: loginModel.isLoggingIn) { newLogin in
                if newLogin {
                    withAnimation {
                        errorMessage = ""
                        serverHint = "Du bist angemeldet!"
                    }
                }
            }
            .onChange(of: serverHint) { _ in
                withAnimation {
                    enterCode = true
                }
            }
            .onChange(of: loginModel.receivedCode) { newCode in
                withAnimation {
                    serverHint = "Server hat folgenden Code geschickt: \"\(newCode)\""
                }
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

