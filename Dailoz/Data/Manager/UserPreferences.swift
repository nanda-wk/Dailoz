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
    @AppStorage("appLang") var appLang = AppLanguage.English.title
    @AppStorage("allowNotification") var allowNotification = false
}
