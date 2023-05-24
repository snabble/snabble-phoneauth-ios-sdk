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

    init(firstStep: Bool = true, showCountdown: Bool = false, disabled: Bool = false) {
        self.firstStep = firstStep
        self.showCountdown = showCountdown
        self.disabled = disabled
    }
    
    private var isDisabled: Bool {
        if loginModel.spamTimerIsActive {
            return true
        }
        return disabled || !loginModel.canRequestCode
    }

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
        .buttonStyle(RequestButtonStyle(firstStep: firstStep, disabled: isDisabled, show: $showCountdown))
        
        .onAppear {
            if !firstStep, loginModel.state == .registered {
                withAnimation {
                    showCountdown = loginModel.spamTimerIsActive
                }
            }
        }
        .onChange(of: loginModel.spamTimerIsActive) { active in
            update(isActive: active)
        }
        .onChange(of: loginModel.isWaiting) { started in
            update(isActive: started)
        }
        .onChange(of: showCountdown) { newState in
            withAnimation {
                disabled = newState
            }
        }
    }
    
    func update(isActive: Bool) {
        withAnimation {
            disabled = isActive
            if !firstStep {
                showCountdown = isActive
            }
        }
    }
}
