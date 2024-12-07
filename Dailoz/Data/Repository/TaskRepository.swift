//
//  TaskRepository.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-03.
//

import Foundation

@MainActor
final class TaskRepository: ObservableObject {
    @Published var tasks: [DTask] = []
    @Published var todayTasks: [DTask] = []
    @Published var taskCountWithStatus: [TStatus: Int] = [:]
    @Published var groupTasks: [String: [DTask]] = [:]
    @Published var isFetching = false

    private let stack = CoreDataStack.shared
    private lazy var moc = stack.viewContext

    func fetchAllTask() {
        let request = DTask.all()
        do {
            tasks = try moc.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }

    func fetchTaskForToday() {
        guard !isFetching else { return }
        isFetching = true
        let request = DTask.fetchTasksForToday()
        do {
            todayTasks = try moc.fetch(request)
        } catch {
            print("Failed to fetch tasks for today: \(error)")
        }
        isFetching = false
    }

    func fetchTaskCount() {
        guard !isFetching else { return }
        isFetching = true
        let request = DTask.fetchTaskCountGroupedByStatus()
        do {
            let fetchedResults = try moc.fetch(request) as? [[String: Any]]
            fetchedResults?.forEach { dictionary in
                if let statusString = dictionary["status"] as? String,
                   let status = TStatus(rawValue: statusString),
                   let count = dictionary["count"] as? Int
                {
                    self.taskCountWithStatus[status] = count
                }
            }
        } catch {
            print("Failed to fetch task count grouped by status: \(error)")
        }
        isFetching = false
    }

    func fetchGroupedTaskByDate(with searchFilter: SearchFilter) {
        guard !isFetching else { return }
        isFetching = true
        let request = DTask.fetchTasks(with: searchFilter)
        do {
            let fetchedResults = try moc.fetch(request)
            let groupedTasks = Dictionary(grouping: fetchedResults) { task -> String in
                task.date.format(.dMMMMyyyy)
            }
            groupTasks = groupedTasks
        } catch {
            print("Failed to fetch grouped tasks: \(error)")
        }
        isFetching = false
    }

    func save(_ task: DTask) {
        let context = task.managedObjectContext ?? moc
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to save task: \(error)")
        }
    }

    func delete(_ task: DTask) {
        let context = task.managedObjectContext ?? moc
        do {
            try stack.delete(task, in: context)
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}
