//
//  TaskListScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-21.
//

import Foundation

final class TaskListScreenVM: ObservableObject {
    @Published var tasks: [TaskEntity] = []

    @Published var searchFilter = SearchFilter()

    @Published private(set) var isLoading = false

    private var offset = 0

    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository = TaskRepository()) {
        self.taskRepository = taskRepository
        searchFilter.date = .init()
        fetchTask()
    }

    func fetchTask(offset: Int? = nil) {
        var ascending = true
        guard !isLoading else { return }
        isLoading = true

        if let offset {
            self.offset = offset
            tasks = []
        }

        if searchFilter.sortByDate == .newest {
            ascending = true
        } else {
            ascending = false
        }

        let fetchedTasks = taskRepository.fetchTasks(
            text: searchFilter.searchText,
            tags: Array(searchFilter.sortByTags),
            types: Array(searchFilter.sortByType),
            monthly: searchFilter.isMonthly ? .init() : nil,
            daily: searchFilter.date,
            ascending: ascending,
            offset: self.offset
        )
        tasks.append(contentsOf: fetchedTasks)
        self.offset += fetchedTasks.count

        isLoading = false
    }

    func onDeleteTask(_ task: TaskEntity) {
        taskRepository.deleteTask(task: task)
        fetchTask()
    }
}
