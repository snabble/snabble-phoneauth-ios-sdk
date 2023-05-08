//
//  RequestCodeButton.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 05.05.23.
//

import SwiftUI
import SnabblePhoneAuth

struct RequestCodeButton: View {
    var firstStep = true
    
    @State private var showCountdown: Bool = false
    @EnvironmentObject var loginModel: PhoneLoginModel

    @ViewBuilder
    var codeSpinner: some View {
        if loginModel.isWaiting {
            ProgressView()
               .padding([.leading], 10)
        }
    }

    var body: some View {
        Button(action: {
            if loginModel.canRequestCode {
                print("request code for \(loginModel.dialString)")
                loginModel.sendPhoneNumber()
            }
        }) {
            HStack {
                Spacer()
                HStack {
                    Text("Code \(firstStep ? "" : "erneut ") anfordern")
                        .fontWeight(.bold)
                    codeSpinner
                }
                Spacer()
            }
        }
        .buttonStyle(RequestButtonStyle(firstStep: firstStep, disabled: !loginModel.canRequestCode, show: $showCountdown))
        .onAppear {
            if !loginModel.receivedCode.isEmpty {
                startCountdown()
            }
        }
        .onChange(of: loginModel.receivedCode) { newCode in
            startCountdown()
        }
        .onChange(of: loginModel.state) { newState in
            if newState == .waitingForCode {
                startCountdown()
            }
            print("state changed to: \(newState)")
        }
    }

    func startCountdown() {
        guard !firstStep else {
            return
        }
        withAnimation {
            showCountdown = true
        }
    }
}

struct RequestCodeButton_Previews: PreviewProvider {
    static let model = PhoneLoginModel()
    static var previews: some View {
        VStack {
            RequestCodeButton(firstStep: true).environmentObject(model)
            RequestCodeButton(firstStep: false).environmentObject(model)
        }
    }
}
