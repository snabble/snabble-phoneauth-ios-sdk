//
//  CountryCallingCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 04.05.23.
//

import SwiftUI
import SnabblePhoneAuth

public struct CountryCallingCodeView: View {
    var country: CountryCallingCode
    @State private var showMenu = false
    @State private var selectedCountry: CountryCallingCode = CountryCallingCodes.defaultCountry
    @EnvironmentObject var loginModel: PhoneLoginModel

    init(country: CountryCallingCode) {
        self.country = country
    }

    public var body: some View {
        HStack {
            if let flag = country.countryCode.countryFlagSymbol {
                Text(flag)
            }
            Button(action: {
                showMenu = true
            }) {
                Text("+\(country.callingCode)")
            }
        }
        .sheet(isPresented: $showMenu, onDismiss: {
            loginModel.country = selectedCountry
        }) {
            CountryCallingCodeListView(selectedCountry: $selectedCountry)
        }
    }
}

public struct CountryCallingCodeListView: View {
    @Binding var selectedCountry: CountryCallingCode
    @Environment(\.dismiss) var dismiss

    public var body: some View {
        List {
            ForEach(CountryCallingCodes.countries, id: \.id) { country in
                CountryCallingCodeRow(country: country)
                    .listRowBackground(UserDefaults.selectedCountry == country.countryCode ? Color.accentColor : Color.clear)
                    .onTapGesture {
                        selectedCountry = country
                        dismiss()
                    }
            }
        }
    }
}

public struct CountryCallingCodeRow: View {
    var country: CountryCallingCode
    
    public var body: some View {
            HStack {
                if let flag = country.countryCode.countryFlagSymbol {
                    Text(flag)
                        .font(.largeTitle)
                }
                VStack(alignment: .leading) {
                    Text("+\(country.callingCode)")
                    Text(country.countryName)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
    }
}
