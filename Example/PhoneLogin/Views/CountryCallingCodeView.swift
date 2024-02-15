//
//  CountryCallingCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 04.05.23.
//

import SwiftUI
import SnabblePhoneAuth

extension CountryCallingCode {
    var name: String {
        Locale.current.localizedString(forRegionCode: countryCode) ?? "n/a"
    }
}

struct CountryCallingCodeView: View {
    let codes: [CountryCallingCode]
    @Binding var selectedCode: CountryCallingCode
    @State private var selection: String?
    
    @State private var showMenu = false
    
    var body: some View {
        HStack {
            Button(action: {
                showMenu = true
            }) {
                if let flag = selectedCode.flagSymbol {
                    Text(flag)
                }
                Text("+\(selectedCode.callingCode)")
            }
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $showMenu, onDismiss: {}) {
            CountryCallingCodeListView(codes: codes, selection: $selection)
        }
        .onChange(of: selection) { value in
            if let value, let code = codes.country(forCode: value) {
                selectedCode = code
            }
        }
        .onAppear {
            selection = selectedCode.id
        }
    }
}

private struct CountryCallingCodeListView: View {
    let codes: [CountryCallingCode]
    @Binding var selection: String?

    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ScrollViewReader { proxy in
            List(codes.sorted(by: { $0.name < $1.name }), selection: $selection) { value in
                CountryCallingCodeRow(code: value)
                    .id(value.id)
                    .onTapGesture {
                        selection = value.id
                        dismiss()
                    }
            }
            .onAppear {
                proxy.scrollTo(selection, anchor: .center)
            }
        }
    }
}

private struct CountryCallingCodeRow: View {
    let code: CountryCallingCode

    public var body: some View {
            HStack {
                if let flag = code.flagSymbol {
                    Text(flag)
                        .font(.largeTitle)
                }
                VStack(alignment: .leading) {
                    Text("+\(code.callingCode)")
                    Text(code.name)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
    }
}
