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
    @Published var taskCountWithStatus: [TStatus: Int] = [:]
    @Published var groupTasks: [String: [DTask]] = [:]
    @Published var isFetching = false

    private var offset = 0

    private let stack = CoreDataStack.shared
    private lazy var moc = stack.viewContext

    func fetchTasks(with searchFilter: SearchFilter, offset: Int? = nil) {
        guard !isFetching else { return }
        isFetching = true
        if let offset {
            self.offset = offset
            tasks = []
        }
        let request = DTask.fetchTasks(with: searchFilter, offset: self.offset)
        do {
            let fetchedTasks = try moc.fetch(request)
            tasks.append(contentsOf: fetchedTasks)
            self.offset += fetchedTasks.count
        } catch {
            print("Failed to fetch tasks: \(error)")
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
