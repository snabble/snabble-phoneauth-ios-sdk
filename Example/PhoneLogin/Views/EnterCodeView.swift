////
////  EnterCodeView.swift
////  PhoneLogin
////
////  Created by Uwe Tilemann on 18.01.23.
////
//
//import SwiftUI
//import SnabblePhoneAuth
//
//public extension PhoneLoginModel {
//    @ViewBuilder
//    var messageView: some View {
//        if !errorMessage.isEmpty {
//            Text(errorMessage)
//                .foregroundColor(.red)
//        }
//    }
//}
//
//public struct EnterCodeView: View {
//    @EnvironmentObject var loginModel: PhoneLoginModel
//    
//    @FocusState private var enterCode
//
//    @ViewBuilder
//    var header: some View {
//        HStack {
//            Spacer()
//            Text("Send \(loginModel.phoneNumberPrettyPrint)")
//            .multilineTextAlignment(.center)
//            Spacer()
//        }
//    }
//    
//    public var body: some View {
//        VStack(spacing: 0) {
//            Form {
//                Section(
//                    header: header,
//                    footer: loginModel.messageView,
//                    content: {
//                            VStack {
//                                TextField("Pin Code", text: $loginModel.oneTimePassword)
//                                    .keyboardType(.decimalPad)
//                                    .focused($enterCode)
//                                
//                                Button(action: {
//                                    loginModel.login()
//                                }) {
//                                    HStack {
//                                        Spacer(minLength: 0)
//                                        HStack {
//                                            Text("Login")
//                                                .fontWeight(.bold)
//                                                .opacity(loginModel.canLogin ? 1.0 : 0.5)
//                                            
//                                            loginModel.progressView
//                                        }
//                                        Spacer(minLength: 0)
//                                    }
//                                }
//                                .buttonStyle(AccentButtonStyle(disabled: !loginModel.canLogin))
//                                
//                                RequestCodeButton(firstStep: false)
//                            }
//                        }
//                    
//                )
//                .textCase(nil)
//            }
//            DebugView()
//        }
//        .onAppear {
//            UserDefaults.pageVisited = .sendOTPPage
//
//            if loginModel.canRequestCode {
//                enterCode = true
//                loginModel.startSpamTimer()
//            }
//        }
//        .padding()
//        .navigationTitle("Input Code")
//    }
//}
