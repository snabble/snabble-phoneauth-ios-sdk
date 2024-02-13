//
//  NumberView.swift
//  teo
//
//  Created by Andreas Osberghaus on 2024-02-07.
//

import SwiftUI
import SnabblePhoneAuth

private struct LabelWithImageAccent: View {
    /// The title which will be passed to the title attribute of the Label View.
    let title: String
    /// The name of the image to pass into the Label View.
    let systemName: String
    
    var body: some View {
        Label(title: {
            Text(self.title)
        }, icon: {
            Image(systemName: systemName)
                .foregroundStyle(.blue)
        })
    }
}

struct NumberView: View {
    let countries: [CountryCallingCode] = CountryCallingCode.default
    
    @State var country: CountryCallingCode = CountryCallingCode(countryCode: "DE", callingCode: 49)
    @State var number: String = ""
    
    @Binding var showProgress: Bool
    @Binding var footerMessage: String
    
    var callback: (_ phoneNumber: String) -> Void
    
    private enum Field: Hashable {
        case phoneNumber
    }
    
    @FocusState private var focusedField: Field?
    
    private var isEnabled: Bool {
        number.count > 3 && !showProgress
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 16) {
                Text("Bitte gib deine Telefonnummer ein:")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
            }
            .padding(.top, 8)
            .font(.callout)
            
            VStack(spacing: 16) {
                HStack {
                    CountryCallingCodeView(codes: countries, selectedCode: $country)
                        .padding(12)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    TextField("Telefonnummer", text: $number)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phoneNumber)
                        .submitLabel(.continue)
                        .padding(12)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .onSubmit {
                            submit()
                        }
                }
                .disabled(showProgress)
                .padding(.horizontal, 24)
                
                ProgressButtonView(
                    title: "Weiter",
                    showProgress: $showProgress,
                    action: {
                        submit()
                })
                .buttonStyle(AccentButtonStyle(disabled: !isEnabled))
                .disabled(!isEnabled)
            }
            
            VStack(spacing: 12) {
                Text(footerMessage)
                    .foregroundColor(.red)
            }
            .font(.footnote)
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .phoneNumber
        }
        .navigationTitle("Anmelden")
    }
    
    private func submit() {
        callback("+\(country.callingCode)\(number)")
    }
}
