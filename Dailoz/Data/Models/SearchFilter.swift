//
//  SearchFilter.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-07.
//

import Foundation

struct SearchFilter: Equatable {
    var searchText: String = ""
    var sortByTags: Set<Tag> = []
    var sortByType: Set<TType> = []
    var sortByDate: SortByDate = .newest
    var status: TStatus?
    var date: Date = .init()
    var isMonthly: Bool = false
}

enum SortByDate: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case newest = "Newest"
    case oldest = "Oldest"
}
