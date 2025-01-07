//
//  Date.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import Foundation

enum DateFormat: String {
    case dMMMMyyyy = "d MMMM yyyy"
    case hhmm_a = "hh:mm a"
    case hhmm = "hh:mm"
    case MMMMyyyy = "MMMM yyyy"
    case E
    case dd
}

extension Date {
    func format(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
