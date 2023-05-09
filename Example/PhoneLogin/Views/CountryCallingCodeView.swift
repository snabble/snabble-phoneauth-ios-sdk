//
//  CountryCallingCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 04.05.23.
//

import SwiftUI
import SnabblePhoneAuth

struct CountryCallingCodeView: View {
    var country: CountryCallingCode
    @State private var showMenu = false
    @State private var selectedCountry: CountryCallingCode = CountryCallingCodes.defaultCountry
    @EnvironmentObject var loginModel: PhoneLoginModel

    init(country: CountryCallingCode) {
        self.country = country
    }

    var body: some View {
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

struct CountryCallingCodeListView: View {
    @Binding var selectedCountry: CountryCallingCode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(CountryCallingCodes.info, id: \.id) { country in
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

struct CountryCallingCodeRow: View {
    var country: CountryCallingCode
    
    var body: some View {
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

struct CountryCallingCodeView_Previews: PreviewProvider {
    static var previews: some View {
        let loginModel = Snabble.development.loginManager

        CountryCallingCodeView(country: CountryCallingCodes.defaultCountry).environmentObject(loginModel)
    }
}
