//
//  TaskRepository.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Combine
import Foundation

final class TaskRepository {
    private let localDataSource: TaskLocalDataSource

    init(localDataSource: TaskLocalDataSource = TaskLocalDataSource()) {
        self.localDataSource = localDataSource
    }

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
        let tasks = localDataSource.fetchTasks(
            text: text,
            tags: tags,
            types: types,
            status: status,
            monthly: monthly,
            daily: daily,
            ascending: ascending,
            offset: offset
        )
        return tasks
    }

    func fetchTasksCount() -> [TStatus: Int] {
        var taskStatusCounts: [TStatus: Int] = [:]
        guard let result = localDataSource.fetchTaskCount() else {
            return [:]
        }
        for dictionary in result {
            if let statusString = dictionary["status"] as? String,
               let status = TStatus(rawValue: statusString),
               let count = dictionary["count"] as? Int
            {
                taskStatusCounts[status] = count
            }
        }
        return taskStatusCounts
    }

    func create(
        title: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        description: String,
        type: TType,
        tags: Set<TagEntity> = [],
        status: TStatus = .pending
    ) -> TaskEntity? {
        let createdTask = localDataSource.create(
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            description: description,
            type: type,
            tags: tags,
            status: status
        )
        return createdTask
    }

    func updateTask(task: TaskEntity) -> TaskEntity? {
        let updatedTask = localDataSource.update(task: task)
        return updatedTask
    }

    func deleteTask(task: TaskEntity) {
        localDataSource.delete(task: task)
    }
}
