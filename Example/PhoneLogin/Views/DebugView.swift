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
    
    var body: some View {
        logsView
    }
}
