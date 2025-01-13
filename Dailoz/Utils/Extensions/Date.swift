//
//  Date.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import Foundation

enum DateFormat: String {
    case ddMMMMyyyy = "dd MMMM yyyy"
    case hhmm_a = "hh:mm a"
    case HHmm = "HH:mm"
    case MMMMyyyy = "MMMM yyyy"
    case E
    case dd
}

extension Date {
    func format(_ format: DateFormat, language: AppLanguage = .en_US) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: language.rawValue)
        return formatter.string(from: self)
    }

    func convertedToCurrentTimeZone() -> Date {
        let timeZoneOffset = TimeZone.current.secondsFromGMT(for: self)
        return Calendar.current.date(byAdding: .second, value: timeZoneOffset, to: self) ?? self
    }
}
