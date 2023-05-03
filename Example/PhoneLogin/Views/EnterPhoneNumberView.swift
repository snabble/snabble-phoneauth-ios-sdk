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
    @State private var phoneNumber = ""
    @State private var isShowingDetailView = false
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    var body: some View {
        VStack {
            NavigationLink(destination: EnterCodeView(phoneNumber: phoneNumber), isActive: $isShowingDetailView) { EmptyView() }
            
            Form {
                Section(
                    content: {
                        HStack{
                            Text(loginModel.countryCode)
                            TextField("Handynummer", text: $phoneNumber)
                                .keyboardType(.phonePad)
                        }
                        
                        Button(action: {
                            isShowingDetailView = true
                            loginModel.sendPhoneNumber(phoneNumber)
                        }) {
                            Text("Code anfordern")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(AccentButtonStyle())
                        
                    },
                    header: {
                        Text("Zum Aktivieren des Logins, gib deine Handynummber ein.\nAnschließend erhälst du eine SMS mit einem Aktivierungscode.")
                            .multilineTextAlignment(.center)
                    }
                )
                .textCase(nil)
            }
            //DebugView()
        }
        .padding()
        .navigationTitle("Telefon-Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}
