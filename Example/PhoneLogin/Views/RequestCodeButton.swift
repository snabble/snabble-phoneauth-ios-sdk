//
//  RequestCodeButton.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 05.05.23.
//

import SwiftUI
import SnabblePhoneAuth

extension PhoneLoginModel {

    @ViewBuilder
    var progressView: some View {
        if isWaiting {
            ProgressView()
               .padding([.leading], 10)
        }
    }
}

struct RequestCodeButton: View {
    var firstStep = true
    
    @State private var showCountdown: Bool = false
    @EnvironmentObject var loginModel: PhoneLoginModel

    var body: some View {
        Button(action: {
            if loginModel.canRequestCode {
                ActionLogger.shared.add(log: LogAction(action: "request code for", info: "\(loginModel.dialString)"))
                loginModel.sendPhoneNumber()
            }
        }) {
            HStack {
                Spacer()
                HStack {
                    Text("Code \(firstStep ? "" : "erneut ") anfordern")
                        .fontWeight(.bold)
                    loginModel.progressView
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

struct RequestCodeButton_Previews: PreviewProvider {
    static let model = PhoneLoginModel()
    static var previews: some View {
        VStack {
            RequestCodeButton(firstStep: true).environmentObject(model)
            RequestCodeButton(firstStep: false).environmentObject(model)
        }
    }
}
