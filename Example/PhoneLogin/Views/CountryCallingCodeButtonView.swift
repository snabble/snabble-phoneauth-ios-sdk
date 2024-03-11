//
//  CountryCallingCodeView.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 04.05.23.
//

import SwiftUI
import SnabblePhoneAuth

extension Country {
    var name: String {
        Locale.current.localizedString(forRegionCode: code) ?? "n/a"
    }
}

struct CountryCallingCodeButtonView: View {
    var countries: [Country]
    @Binding var selectedCountry: Country
        
    @State private var selection: String?
    @State private var showMenu = false
    
    var body: some View {
        HStack {
            Button(action: {
                showMenu = true
            }) {
                if let flag = selectedCountry.flagSymbol {
                    Text(flag)
                }
                if let code = selectedCountry.callingCode {
                    Text("+\(code)")
                }
            }
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $showMenu, onDismiss: {}) {
            CountryCallingCodeListView(countries: countries, selection: $selection)
        }
        .onChange(of: selection) { value in
            if let value, let country = countries.country(forCode: value) {
                selectedCountry = country
            }
        }
        .onAppear {
            selection = selectedCountry.id
        }
    }
}

private struct CountryCallingCodeListView: View {
    let countries: [Country]
    @Binding var selection: String?
    @State private var searchText = ""

    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ScrollViewReader { proxy in
            NavigationStack {
                List(searchResults, selection: $selection) { value in
                    CountryCallingCodeRow(country: value)
                        .id(value.id)
                        .onTapGesture {
                            selection = value.id
                            dismiss()
                        }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Choose your country")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear {
                proxy.scrollTo(selection, anchor: .center)
            }
        }
    }
    var searchResults: [Country] {
        if searchText.isEmpty {
            return countries.sorted(by: { $0.name < $1.name })
        } else {
            return countries.sorted(by: { $0.name < $1.name }).filter { $0.name.contains(searchText) }
        }
    }
}

private struct CountryCallingCodeRow: View {
    let country: Country

    public var body: some View {
        HStack {
            if let flag = country.flagSymbol {
                Text(flag)
                    .font(.largeTitle)
            }
            VStack(alignment: .leading) {
                if let code = country.callingCode {
                    Text("+\(code)")
                }
                Text(country.name)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
    }
}
