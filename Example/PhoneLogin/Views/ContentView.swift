//
//  ContentView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 17.01.23.
//

import SwiftUI

struct LoggedInView: View {
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    var body: some View {
        VStack {
            Text("Du bis eingeloggt!")
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
    
    var body: some View {
        NavigationView {
            if loginModel.state == .loggedIn {
                LoggedInView()
            } else {
                EnterPhoneNumberView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
