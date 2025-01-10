//
//  TaskOverviewScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-26.
//

import Foundation

@MainActor
final class TaskOverviewScreenVM: ObservableObject {
    @Published var tasks: [String: [TaskEntity]] = [:]

    @Published var searchFilter = SearchFilter()

    @Published private(set) var isLoading = false

    private var offset = 0

    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository = TaskRepository()) {
        self.taskRepository = taskRepository
    }

    func fetchTasks(offset: Int? = nil, lang: AppLanguage = .en_US) {
        guard !isLoading else { return }
        isLoading = true

        if let offset {
            self.offset = offset
            tasks = [:]
        }

        let fetchedTasks = taskRepository.fetchTasksGroupedByHour(
            text: searchFilter.searchText,
            date: searchFilter.date,
            hourly: true,
            offset: self.offset,
            lang: lang
        )
        for (date, newTasks) in fetchedTasks {
            if tasks[date] != nil {
                tasks[date]?.append(contentsOf: newTasks)
            } else {
                tasks[date] = newTasks
            }
        }
        self.offset += fetchedTasks.count

        isLoading = false
    }

    func onDeleteTask(_ task: TaskEntity) {
        taskRepository.deleteTask(task: task)
        fetchTasks(offset: 0)
    }
}
