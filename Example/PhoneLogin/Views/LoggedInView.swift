//
//  LoggedInView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 15.05.23.
//

import SwiftUI
import SnabblePhoneAuth

struct LoggedInView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    @ViewBuilder
    var info: some View {
        if let appID = UserDefaults.appUser?.id {
            Text(appID)
                .font(.custom("Menlo", size: 12))
        }
    }
    var isLoggedIn: Bool {
        return loginModel.state == .loggedIn
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text(isLoggedIn ? "You are logged in!" : "You are not logged in!")
                    .font(.largeTitle)
                info
                
                loginModel.messageView
                    .padding()
                
                Spacer()
                DebugView()
            }
            loginModel.progressView
        }
        .padding()
        .onAppear {
            UserDefaults.pageVisited = .loggedInPage
        }
        .onChange(of: loginModel.state) { state in
            if state == .start {
                UserDefaults.pageVisited = .startPage
                dismiss()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    loginModel.deleteAccount()
                }) {
                    Image(systemName: "trash")
                }
                .disabled(loginModel.isWaiting)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    loginModel.logout()

                    UserDefaults.lastPageVisited = nil
                    presentationMode.wrappedValue.dismiss()
                    dismiss()
                }) {
                    Text(loginModel.isLoggedIn ? "Logout" : "Close")
                }
                .disabled(loginModel.isWaiting)
            }
        }
    }
}
