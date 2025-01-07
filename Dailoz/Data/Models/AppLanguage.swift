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

    case English
    case Myanmar

    var title: String {
        switch self {
        case .English:
            "English"
        case .Myanmar:
            "Myanmar"
        }
    }
}
