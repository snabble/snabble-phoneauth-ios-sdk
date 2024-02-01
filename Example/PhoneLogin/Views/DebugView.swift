////
////  DebugView.swift
////  PhoneLogin
////
////  Created by Uwe Tilemann on 03.05.23.
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//import SnabblePhoneAuth
//
//extension LogAction {
//    var textColor: Color {
//        return action.hasPrefix("enter") ? .green : (action.hasPrefix("leave") || action == "error" ? .red : .primary)
//    }
//    
//    var view: some View {
//        HStack {
//            Text(timeStamp.formatted(date: .omitted, time: .standard))
//                .foregroundColor(.secondary)
//            HStack {
//                Text(action)
//                    .fontWeight(.bold)
//                
//                if !info.isEmpty {
//                    Text(info)
//                        .foregroundColor(textColor)
//                }
//                Spacer()
//            }
//        }
//        .font(.custom("Menlo", size: 11))
//    }
//}
//
//struct DebugView: View {    
//    @EnvironmentObject var loginModel: PhoneLoginModel
//    @StateObject var logger = ActionLogger.shared
//    
//    @ViewBuilder
//    var logsView: some View {
//        if UserDefaults.logActions {
//            ScrollViewReader { value in
//                ScrollView(.vertical) {
//                    ForEach(logger.logs, id: \.id) { log in
//                        log.view
//                            .id(log.id)
//                   }
//                }
//                .frame(minHeight: 12, maxHeight: 100)
//                .onChange(of: logger.logs.count) { _ in
//                    value.scrollTo(logger.logs.last?.id)
//                }
//                .onAppear {
//                    value.scrollTo(logger.logs.last?.id)
//                }
//           }
//        }
//    }
//        
//    var body: some View {
//        logsView
//    }
//}
