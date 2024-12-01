//
//  TType.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import Foundation

enum TType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case personal = "Personal"
    case tPrivate = "Private"
    case secret = "Secret"
}
