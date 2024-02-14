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
    
    @State private var showMenu = false
    
    var body: some View {
        HStack {
            if let flag = selectedCode.flagSymbol {
                Text(flag)
            }
            Button(action: {
                showMenu = true
            }) {
                Text("+\(selectedCode.callingCode)")
            }
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $showMenu, onDismiss: {}) {
            CountryCallingCodeListView(codes: codes, selectedCode: $selectedCode)
        }
    }
}

private struct CountryCallingCodeListView: View {
    @State var codes: [CountryCallingCode]
    @Binding var selectedCode: CountryCallingCode

    @Environment(\.dismiss) var dismiss

    public var body: some View {
        List {
            ForEach(codes.sorted(by: { $0.name < $1.name }), id: \.countryCode) { value in
                CountryCallingCodeRow(code: value, isSelected: value == selectedCode)
                    .onTapGesture {
                        self.selectedCode = value
                        dismiss()
                    }
            }
        }
    }
}

private struct CountryCallingCodeRow: View {
    let code: CountryCallingCode
    let isSelected: Bool

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
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
    }
}
