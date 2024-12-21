//
//  TaskLocalDataSource.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Foundation

final class TaskLocalDataSource {
    private let stack = CoreDataStack.shared
    private lazy var moc = stack.viewContext

    func fetchTasks(
        text: String = "",
        tags: [TagEntity] = [],
        types: [TType] = [],
        status: [TStatus] = [],
        monthly: Date? = nil,
        daily: Date? = nil,
        ascending: Bool = false,
        offset: Int = 0
    ) -> [TaskEntity] {
        let fetchRequest = TaskEntity.fetchTasks(
            text: text,
            tags: tags,
            types: types,
            status: status,
            monthly: monthly,
            daily: daily,
            ascending: ascending,
            offset: offset
        )
        do {
            let fetchedTasks = try moc.fetch(fetchRequest)
            return fetchedTasks
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
        return []
    }

    func fetchTaskCount() -> [[String: Any]]? {
        let fetchReqest = TaskEntity.fetchTaskCountGroupedByStatus()
        do {
            let fetchedResults = try moc.fetch(fetchReqest) as? [[String: Any]]
            return fetchedResults
        } catch {
            print("failed to fetch task count grouped by status: \(error)")
        }
        return nil
    }

    func create(
        title: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        description: String,
        type: TType,
        tags: Set<TagEntity>,
        status: TStatus
    ) -> TaskEntity? {
        let entity = TaskEntity(context: moc)
        entity.title = title
        entity.date = date
        entity.startTime = startTime
        entity.endTime = endTime
        entity.tDescription = description
        entity.type = type.rawValue
        entity.status = status.rawValue
        entity.tags = tags
        guard let context = entity.managedObjectContext else {
            return nil
        }

        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to create task: \(error)")
        }
        return entity
    }

    func update(task: TaskEntity) -> TaskEntity? {
        guard let context = task.managedObjectContext else {
            return nil
        }
        do {
            try stack.persist(in: context)
            return task
        } catch {
            print("Failed to update task: \(error)")
        }
        return nil
    }

    func delete(task: TaskEntity) {
        guard let context = task.managedObjectContext else {
            return
        }
        do {
            try stack.delete(task, in: context)
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}
