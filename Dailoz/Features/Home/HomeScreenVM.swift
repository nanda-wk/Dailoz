//
//  HomeScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-12.
//

import Combine
import SwiftUI

@MainActor
final class HomeScreenVM: ObservableObject {
    @Published private(set) var tasks: [TaskEntity] = [] {
        didSet {
            tasksIsEmpty = tasks.isEmpty
        }
    }

    @Published private(set) var completedCount = 0
    @Published private(set) var pendingCount = 0
    @Published private(set) var canceledCount = 0
    @Published private(set) var onGoingCount = 0

    @Published var firstName = "Nanda"
    @Published var profileImage: Image = .init(.avatarDummy)
    @Published var tasksIsEmpty = false

    @Published private(set) var isLoading = false

    private let taskRepository: TaskRepository
    private var cancellables: Set<AnyCancellable> = []

    init(taskRepository: TaskRepository = TaskRepository()) {
        self.taskRepository = taskRepository
    }

    func fetchTask() {
        guard !isLoading else { return }
        isLoading = true
        let taskStatusCount = taskRepository.fetchTasksCount()
        completedCount = taskStatusCount[.completed] ?? 0
        pendingCount = taskStatusCount[.pending] ?? 0
        canceledCount = taskStatusCount[.canceled] ?? 0
        onGoingCount = taskStatusCount[.onGoing] ?? 0

        tasks = taskRepository.fetchTasks(daily: .init())
        isLoading = false
    }

    func onDeleteTask(_ task: TaskEntity) {
        taskRepository.deleteTask(task: task)
        fetchTask()
    }
}
