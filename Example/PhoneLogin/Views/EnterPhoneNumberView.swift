//
//  EnterPhoneNumberView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import SwiftUI
import SnabblePhoneAuth

struct EnterPhoneNumberView: View {
    @State private var isShowingDetailView = false
    @State private var canSend = false
    @EnvironmentObject var loginModel: PhoneLoginModel

    @FocusState private var enterCode
    
    @ViewBuilder
    var spinner: some View {
        if loginModel.state == .pushedToServer {
            ProgressView()
               .padding([.leading], 10)
        }
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: EnterCodeView(phoneNumber: loginModel.phoneNumber), isActive: $isShowingDetailView) { EmptyView() }
            
            Form {
                Section(
                    content: {
                        VStack {
                            HStack{
                                CountryCallingCodeView(country: loginModel.country)
                                
                                TextField("Handynummer", text: $loginModel.phoneNumber)
                                    .keyboardType(.phonePad)
                                    .focused($enterCode)
                            }
                            RequestCodeButton(firstStep: true)
                        }
                        .padding([.leading, .trailing], 20)
                    },
                    header: {
                        Text("Zum Aktivieren des Logins, gib deine Handynummber ein.\nAnschließend erhälst du eine SMS mit einem Aktivierungscode.")
                            .multilineTextAlignment(.center)
                    },
                    footer: {
                        if !loginModel.errorMessage.isEmpty {
                            Text(loginModel.errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                )
                .textCase(nil)
            }
            .onChange(of: loginModel.receivedCode) { newCode in
                isShowingDetailView = !newCode.isEmpty
            }
            .onAppear {
                enterCode = true
                canSend = loginModel.canSendPhoneNumber
            }
            .onChange(of: loginModel.phoneNumber) { _ in
                canSend = loginModel.canSendPhoneNumber
            }
            //DebugView()
        }
        .padding()
        .navigationTitle("Telefon-Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}
