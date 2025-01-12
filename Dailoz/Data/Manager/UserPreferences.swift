//
//  UserPreferences.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-06.
//

import Foundation
import SwiftUI

final class UserPreferences: ObservableObject {
    @AppStorage("userName") var userName = ""
    @AppStorage("isFirstLunch") var isFirstLunch = true
    @AppStorage("appLang") var appLang: AppLanguage = .en_US
    @AppStorage("allowNotification") var allowNotification = false

    private var bundle: Bundle = .main

    func setLanguage() {
        let languageCode = appLang.rawValue
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let newBundle = Bundle(path: path)
        else {
            print("Localization for \(languageCode) not found. Falling back to default.")
            bundle = .main
            return
        }
        bundle = newBundle
    }
}
