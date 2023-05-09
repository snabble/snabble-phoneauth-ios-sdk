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
    @EnvironmentObject var loginModel: PhoneLoginModel

    @FocusState private var enterCode
        
    var body: some View {
        VStack {
            NavigationLink(destination: EnterCodeView(), isActive: $isShowingDetailView) { EmptyView() }
            
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
                        loginModel.messageView
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
            DebugView(debugConfig: .logs)
        }
        .padding()
        .navigationTitle("Telefon-Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}
