//
//  ActivityScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-01.
//

import Foundation
import SwiftUI

final class ActivityScreenVM: ObservableObject {
    @Published var weklyData: [ChartData] = []
    @Published var previous12DaysData: [ChartData] = []

    @Published private(set) var isLoading = false

    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository = TaskRepository()) {
        self.taskRepository = taskRepository
    }

    func fetchData(lang: AppLanguage = .en_US) {
        guard !isLoading else { return }
        isLoading = true

        withAnimation(.bouncy) {
            self.weklyData = taskRepository.fetchTasksForWeeklyChart(for: .init(), lang: lang)
        }

        withAnimation(.bouncy) {
            self.previous12DaysData = taskRepository.fetchTasksForPrevious12Days(from: .init(), lang: lang)
        }

        isLoading = false
    }
}
