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
            content
        }
    }
    private var content: some View {
        switch loginModel.state {
        case .loggedIn:
            return AnyView(LoggedInView())
            
        default:
            return AnyView(EnterPhoneNumberView())
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
