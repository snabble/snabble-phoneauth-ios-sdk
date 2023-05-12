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
    @State private var disabled: Bool = false
    
    @EnvironmentObject var loginModel: PhoneLoginModel
    
    public var body: some View {
        Button(action: {
            loginModel.sendPhoneNumber()
        }) {
            HStack {
                Spacer(minLength: 0)
                HStack {
                    Text(firstStep ? "Request Code" : "Request Code Again")
                        .fontWeight(.bold)
                    loginModel.progressView
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(RequestButtonStyle(firstStep: firstStep, disabled: isDisabled, show: $showCountdown, sendDate: $loginModel.waitTimer.startTime))
        
        .onAppear {
            if firstStep == false, loginModel.state == .waitingForCode {
                disabled = true
                startCountdown()
            }
        }
        .onChange(of: loginModel.state) { newState in
            if firstStep == false, newState == .waitingForCode {
                startCountdown()
            }
        }
        .onChange(of: showCountdown) { newState in
            withAnimation {
                disabled = newState
            }
        }
    }
    var isDisabled: Bool {
        if loginModel.waitTimer.isRunning {
            return true
        }
        return disabled || !loginModel.canRequestCode
    }
    
    func startCountdown() {
        guard !firstStep else {
            return
        }
        loginModel.startTimer()
        
        withAnimation {
            showCountdown = true
        }
    }
}
