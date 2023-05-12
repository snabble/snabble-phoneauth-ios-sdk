//
//  EnterPhoneNumberView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import SwiftUI
import SnabblePhoneAuth

public struct EnterPhoneNumberView: View {
    @State var isShowingDetailView = false
    @EnvironmentObject var loginModel: PhoneLoginModel

    @FocusState private var enterCode

    public var body: some View {
        VStack {
            NavigationLink(destination: EnterCodeView(), isActive: $isShowingDetailView) { EmptyView() }
            
            Form {
                Section(
                    content: {
                        VStack {
                            HStack {
                                CountryCallingCodeView(country: loginModel.country)
                                
                                TextField("Handynummer", text: $loginModel.phoneNumber)
                                    .keyboardType(.phonePad)
                                    .focused($enterCode)
                            }
                            RequestCodeButton(firstStep: true)
                        }
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
            .onChange(of: loginModel.state) { _ in
                isShowingDetailView = UserDefaults.phoneNumber?.isEmpty == false
            }
            .onAppear {
                UserDefaults.pageVisited = .startPage
                enterCode = true
            }
            DebugView()
        }
        .padding()
        .navigationTitle("Telefon-Login")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if loginModel.codeWasSendOnce {
                    Button(action: {
                        withAnimation {
                            isShowingDetailView = true
                        }
                    }) {
                        Text("Anmelden")
                    }
                }
            }
        }
    }
}
