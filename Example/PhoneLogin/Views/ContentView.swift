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
        case loginPage
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
    
    var body: some View {
        VStack {
            Text("Du bist eingeloggt!")
                .font(.largeTitle)
            
            Button(action: {
                withAnimation {
                    loginModel.logout()
                }
            }) {
                Text("Logout")
                    .padding()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    var showDetail: Bool {
        return UserDefaults.pageVisited == .loginPage
    }
    
    var body: some View {
        NavigationView {
            if loginModel.isLoggedIn {
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
