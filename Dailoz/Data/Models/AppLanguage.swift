//
//  AppLanguage.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-06.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    var id: String {
        rawValue
    }

    case en_US
    case my_MM

    func title(_ lang: Self) -> String {
        switch self {
        case .en_US:
            lang == .en_US ? "English" : "အင်္ဂလိပ်"
        case .my_MM:
            lang == .en_US ? "Myanmar" : "မြန်မာ"
        }
    }
}
