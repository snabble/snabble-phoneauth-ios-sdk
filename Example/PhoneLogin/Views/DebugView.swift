//
//  DebugView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 03.05.23.
//

import Foundation
import SwiftUI
import Combine
import SnabblePhoneAuth

enum DebugConfig {
    case hidden
    case logs
    case toogles
    case logsAndToggles
}

struct DebugView: View {
    let debugConfig: DebugConfig
    
    @EnvironmentObject var loginModel: PhoneLoginModel
    @State private var userInfo: [String: Any] = [:]
    @State private var errorCode = false
    @State private var errorLogin = false
    @StateObject var logger = ActionLogger.shared
    
    @ViewBuilder
    var logsView: some View {
        ScrollView(.vertical) {
            ForEach(logger.logs, id: \.id) { log in
                HStack {
                    Text(log.timeStamp.formatted(date: .omitted, time: .standard))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text(log.action)
                        .fontWeight(.bold)
                    
                    if !log.info.isEmpty {
                        Text(log.info)
                            .foregroundColor(log.action.hasPrefix("enter") ? .green : (log.action.hasPrefix("leave") ? .red : .primary))
                    }
                    Spacer()
                }
                .font(.custom("Menlo", size: 13))
            }
        }
        .frame(minHeight: 12, maxHeight: 200)
    }
    
    @ViewBuilder
    var togglesView: some View {
        Toggle(isOn: $errorCode) {
            Text("Test error on request code")
        }
        .onChange(of: errorCode) { _ in
            updateUserInfo()
        }
        Toggle(isOn: $errorLogin) {
            Text("Test error on login")
        }
        .onChange(of: errorLogin) { _ in
            updateUserInfo()
        }
    }
    @ViewBuilder
    var logsAndTogglesView: some View {
        VStack {
            logsView
            togglesView
        }
    }

    @ViewBuilder
    var content: some View {
        
        if debugConfig == .logs {
            logsView
        } else if debugConfig == .toogles {
            togglesView
        } else if debugConfig == .logsAndToggles {
            logsAndTogglesView
        }
    }
    
    var body: some View {
        content
        .onAppear {
            if let error = loginModel.userInfo["error"] as? FakeEndpointError, error == .phoneNumberError {
                errorCode = true
            }
            if let error = loginModel.userInfo["error"] as? FakeEndpointError, error == .loginError {
                errorLogin = true
            }
        }
    }
    
    private func updateUserInfo() {
        userInfo = [:]
        if errorCode {
            userInfo["error"] = FakeEndpointError.phoneNumberError
        } else if errorLogin {
            userInfo["error"] = FakeEndpointError.loginError
        }
        if loginModel.state == .error, userInfo.isEmpty {
            loginModel.userInfo = userInfo
            loginModel.reset()
        }
        if !userInfo.isEmpty {
            loginModel.userInfo = userInfo
        }
        if !loginModel.userInfo.isEmpty, userInfo.isEmpty {
            loginModel.userInfo = userInfo
        }
    }
}
