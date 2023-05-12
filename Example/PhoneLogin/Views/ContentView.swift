//
//  ContentView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 17.01.23.
//

import SwiftUI
import SnabblePhoneAuth

extension UserDefaults {
    private enum Keys {
        static let lastPageVisited = "lastPage"
    }
    public enum Pages: String {
        case startPage
        case sendOTPPage
        case loggedInPage
    }
    public class var pageVisited: Pages? {
        get {
            if let page = lastPageVisited {
                return Pages(rawValue: page)
            }
            return nil
        }
        set {
            lastPageVisited = newValue?.rawValue
        }

    }

    public class var lastPageVisited: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.lastPageVisited)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.lastPageVisited)
            UserDefaults.standard.synchronize()
        }
    }
}

struct LoggedInView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    @ViewBuilder
    var info: some View {
        if let appID = loginModel.appUser?.id {
            Text(appID)
                .font(.custom("Menlo", size: 12))
        }
    }
    
    var body: some View {
        VStack {
            Text(loginModel.isLoggedIn ? "You are logged in!" : "You are not logged in!")
                .font(.largeTitle)
            info
            
            loginModel.messageView
                .padding()

            Spacer()
            DebugView()
        }
        .padding()
        .onAppear {
            UserDefaults.pageVisited = .loggedInPage
        }
        .onChange(of: loginModel.state) { newState in
            if newState == .start {
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
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if loginModel.isLoggedIn {
                        loginModel.logout()
                    }
                    UserDefaults.lastPageVisited = nil
                    presentationMode.wrappedValue.dismiss()
                    dismiss()
                }) {
                    Text(loginModel.isLoggedIn ? "Logout" : "Close")
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    @State private var isLoggedIn = false
    
    var showDetail: Bool {
        guard !isLoggedIn else {
            return false
        }
        return UserDefaults.pageVisited == .sendOTPPage && UserDefaults.phoneNumber?.isEmpty == false
    }

    var body: some View {
        NavigationView {
            if isLoggedIn {
                LoggedInView()
            } else {
                EnterPhoneNumberView(isShowingDetailView: showDetail)
            }
        }
        .onAppear {
            isLoggedIn = UserDefaults.pageVisited == .loggedInPage || loginModel.isLoggedIn
        }
        .onChange(of: loginModel.state) { newState in
            if newState == .loggedIn {
                isLoggedIn = true
            } else if newState == .start {
                isLoggedIn = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
