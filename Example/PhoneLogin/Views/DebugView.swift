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

extension LogAction {
    var view: some View {
        HStack {
            Text(timeStamp.formatted(date: .omitted, time: .standard))
                .foregroundColor(.secondary)
            HStack {
                Text(action)
                    .fontWeight(.bold)
                
                if !info.isEmpty {
                    Text(info)
                        .foregroundColor(action.hasPrefix("enter") ? .green : (action.hasPrefix("leave") ? .red : .primary))
                }
                Spacer()
            }
        }
            .font(.custom("Menlo", size: 11))
    }
}

struct DebugView: View {    
    @EnvironmentObject var loginModel: PhoneLoginModel
    @StateObject var logger = ActionLogger.shared
    
    @ViewBuilder
    var logsView: some View {
        if loginModel.logActions {
            ScrollView(.vertical) {
                ForEach(logger.logs, id: \.id) { log in
                    log.view
                }
            }
            .frame(minHeight: 12, maxHeight: 100)
        }
    }
    
    var body: some View {
        logsView
    }
}
