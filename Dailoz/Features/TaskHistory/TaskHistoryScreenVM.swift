//
//  TaskHistoryScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-22.
//

import Foundation

final class TaskHistoryScreenVM: ObservableObject {
    @Published var tasks: [String: [TaskEntity]] = [:]

    @Published var searchFilter = SearchFilter()

    @Published private(set) var isLoading = false

    private var offset = 0

    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository = TaskRepository()) {
        self.taskRepository = taskRepository
        searchFilter.isMonthly = true
    }

    func fetchTasks(offset: Int? = nil, lang: AppLanguage = .en_US) {
        guard !isLoading else { return }
        isLoading = true

        if let offset {
            self.offset = offset
            tasks = [:]
        }

        var statusList: [TStatus] = []
        if let status = searchFilter.status {
            statusList.append(status)
        }

        let fetchedTasks = taskRepository.fetchTasksGroupedByDate(
            text: searchFilter.searchText,
            tags: Array(searchFilter.sortByTags),
            types: Array(searchFilter.sortByType),
            status: statusList,
            monthly: searchFilter.isMonthly ? searchFilter.date : nil,
            offset: self.offset,
            lang: lang
        )
        for (date, newTasks) in fetchedTasks.sorted(by: {$0.key > $1.key}) {
            if tasks[date] != nil {
                tasks[date]?.append(contentsOf: newTasks)
            } else {
                tasks[date] = newTasks
            }
        }

        self.offset += fetchedTasks.count

        isLoading = false
    }
}
