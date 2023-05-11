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
    
    @ViewBuilder
    var info: some View {
        if let appID = UserDefaults.appUser?.id {
            Text(appID)
                .font(.custom("Menlo", size: 12))
        }
    }
    
    var body: some View {
        VStack {
            Text("Du bist eingeloggt!")
                .font(.largeTitle)
            info
            
            loginModel.messageView
                .padding()

            Spacer()
            DebugView()
        }
        .onAppear {
            UserDefaults.pageVisited = .loggedInPage
        }
        .padding()
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
                    loginModel.logout()
                    UserDefaults.lastPageVisited = nil
                }) {
                    Text("Logout")
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    var showDetail: Bool {
        guard !isLoggedIn else {
            return false
        }
        return UserDefaults.pageVisited == .sendOTPPage && UserDefaults.phoneNumber?.isEmpty == false
    }
    var isLoggedIn: Bool {
        return UserDefaults.pageVisited == .loggedInPage || loginModel.isLoggedIn
    }
    var body: some View {
        NavigationView {
            if isLoggedIn {
                LoggedInView()
            } else {
                EnterPhoneNumberView(isShowingDetailView: showDetail)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
