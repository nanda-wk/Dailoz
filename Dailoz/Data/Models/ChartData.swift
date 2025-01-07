//
//  ChartData.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-01.
//

import Foundation

struct ChartData: Identifiable, Equatable {
    let id = UUID()
    let date: String
    let type: TType
    let count: Int
}
