//
//  EnterPhoneNumberView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import SwiftUI
import SnabblePhoneAuth

struct CountryCallingCodeView: View {
    var country: CountryCallingCode
    
    var body: some View {
        HStack {
            if let flag = country.countryCode.countryFlagSymbol {
                Text(flag)
                    .font(.largeTitle)
            }
            VStack(alignment: .leading) {
                Text("+\(country.callingCode)")
                Text(country.countryName)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
    }
}

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
                            HStack{
                                Text("+\(loginModel.country.callingCode)")
                                
                                TextField("Handynummer", text: $loginModel.phoneNumber)
                                    .keyboardType(.phonePad)
                                    .focused($enterCode)
                            }
                            
                            Button(action: {
                                loginModel.sendPhoneNumber()
                            }) {
                                HStack {
                                    Text("Code anfordern")
                                        .fontWeight(.bold)
                                        .opacity(canSend ? 1.0 : 0.5)
                                    spinner
                                }
                            }
                            .disabled(!canSend)
                            .buttonStyle(AccentButtonStyle())
                            
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
