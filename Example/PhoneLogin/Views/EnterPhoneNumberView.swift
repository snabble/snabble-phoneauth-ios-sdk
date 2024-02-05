////
////  EnterPhoneNumberView.swift
////  PhoneLogin
////
////  Created by Uwe Tilemann on 18.01.23.
////
//
//import Foundation
//import SwiftUI
//import SnabblePhoneAuth
//
//public struct EnterPhoneNumberView: View {
//    @Binding var countryCallingCode: CountryCallingCode
//    @Binding var phoneNumber: String?
//    
//    @State var isButtonEnabled: Bool = false
//
//    public var body: some View {
//        VStack {
//            TextField("", text: $username)
//                .focused($focusedField, equals: .username)
//
//            SecureField("Enter your password", text: $password)
//                .focused($focusedField, equals: .password)
//        }
//    }
//}
