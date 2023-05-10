//
//  RequestCodeButton.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 05.05.23.
//

import SwiftUI

import SnabblePhoneAuth

public extension PhoneLoginModel {

    @ViewBuilder
    var progressView: some View {
        if isWaiting {
            ProgressView()
               .padding([.leading], 10)
        }
    }
}

public struct RequestCodeButton: View {
    public var firstStep = true
    
    @State private var showCountdown: Bool = false
    @EnvironmentObject var loginModel: PhoneLoginModel

    public var body: some View {
        Button(action: {
            loginModel.sendPhoneNumber()
        }) {
            HStack {
                Spacer(minLength: 0)
                HStack {
                    Text("Code \(firstStep ? "" : "erneut ") anfordern")
                        .fontWeight(.bold)
                    loginModel.progressView
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(RequestButtonStyle(firstStep: firstStep, disabled: !loginModel.canRequestCode, show: $showCountdown))
        
        .onAppear {
            if !loginModel.receivedCode.isEmpty {
                startCountdown()
            }
        }
        .onChange(of: loginModel.receivedCode) { _ in
            startCountdown()
        }
        .onChange(of: loginModel.state) { newState in
            if newState == .waitingForCode {
                startCountdown()
            }
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
