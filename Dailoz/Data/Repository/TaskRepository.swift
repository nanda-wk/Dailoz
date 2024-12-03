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
        let request = DTask.fetchTasksForToday()
        do {
            todayTasks = try moc.fetch(request)
        } catch {
            print("Failed to fetch tasks for today: \(error)")
        }
    }

    func save(_ task: DTask) {
        let context = task.managedObjectContext ?? moc
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}
