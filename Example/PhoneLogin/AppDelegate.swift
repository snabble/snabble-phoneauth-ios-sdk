//
//  AppDelegate.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 15.05.23.
//

import Foundation
import UIKit
import SnabblePhoneAuth

class AppDelegate: NSObject, UIApplicationDelegate, CountryProviding {
    var countries: [SnabblePhoneAuth.CountryCallingCode]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        CountryProvider.provider = self
        countries = loadJSON("Countries")
        return true
    }
    func supportedCountries() -> [SnabblePhoneAuth.CountryCallingCode]? {
        countries
    }
}
