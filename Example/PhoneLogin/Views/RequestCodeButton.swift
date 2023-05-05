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
    @State private var disabled: Bool = false
    @State var sendDate: Date = .now

    @EnvironmentObject var loginModel: PhoneLoginModel

    @ViewBuilder
    var codeSpinner: some View {
        if loginModel.state == .pushedToServer {
            ProgressView()
               .padding([.leading], 10)
        }
    }

    var body: some View {
        Button(action: {
            if canRequestCode {
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
        .buttonStyle(RequestButtonStyle(firstStep: firstStep, disabled: isDisabled, show: $showCountdown))
        .onAppear {
            if !loginModel.receivedCode.isEmpty {
                startCountdown()
            }
        }
        .onChange(of: loginModel.receivedCode) { newCode in
            startCountdown()
        }
        .onChange(of: showCountdown) { newValue in
            if newValue == false {
                withAnimation {
                    disabled = false
                }
            }
        }
        .onChange(of: loginModel.state) { newState in
            if newState == .waitingForCode {
                startCountdown()
            }
            print("state changed to: \(newState)")
        }
    }
    var isDisabled: Bool {
        disabled || loginModel.isWaiting
    }

    func startCountdown() {
        withAnimation {
            disabled = true
            if !firstStep {
                showCountdown = true
            }
        }
    }

    var canRequestCode: Bool {
        guard showCountdown == false else {
            return false
        }
        return firstStep ? loginModel.canSendPhoneNumber : loginModel.canRequestCode
    }
}

struct RequestCodeButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RequestCodeButton(firstStep: true)
            RequestCodeButton(firstStep: false)
        }
    }
}
