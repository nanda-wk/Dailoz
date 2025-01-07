//
//  TaskEntity.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import CoreData
import Foundation
import SwiftUICore

final class TaskEntity: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var date: Date
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date
    @NSManaged var tDescription: String
    @NSManaged var type: String
    @NSManaged var status: String
    @NSManaged var tags: Set<TagEntity>

    var typeEnum: TType {
        if let type = TType(rawValue: type) {
            type
        } else {
            .personal
        }
    }

    var statusEnum: TStatus {
        if let status = TStatus(rawValue: status) {
            status
        } else {
            .pending
        }
    }

    var timeRange: String {
        let start = startTime.format(.hhmm)
        let end = endTime.format(.hhmm)
        return "\(start) - \(end)"
    }

    var color: Color {
        switch statusEnum {
        case .completed:
            .completed
        case .pending:
            .pending
        case .canceled:
            .canceled
        case .onGoing:
            .ongoing
        }
    }

    var bgColor: Color {
        switch statusEnum {
        case .completed:
            .completedBG
        case .pending:
            .pendingBG
        case .canceled:
            .canceledBG
        case .onGoing:
            .ongoingBG
        }
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(Date(), forKey: "date")
        setPrimitiveValue(Date(), forKey: "startTime")
        setPrimitiveValue(Date(), forKey: "endTime")
        setPrimitiveValue(TType.personal.rawValue, forKey: "type")
        setPrimitiveValue(TStatus.pending.rawValue, forKey: "status")
    }
}

extension TaskEntity {
    static var taskFetchRequest: NSFetchRequest<TaskEntity> {
        NSFetchRequest(entityName: "TaskEntity")
    }

    static func all() -> NSFetchRequest<TaskEntity> {
        let request: NSFetchRequest<TaskEntity> = taskFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false),
        ]
        return request
    }

    static func fetchTasks(
        text: String = "",
        tags: [TagEntity] = [],
        types: [TType] = [],
        status: [TStatus] = [],
        monthly: Date? = nil,
        daily: Date? = nil,
        hourly: Bool = false,
        ascending: Bool = false,
        batchSize _: Int = 20,
        offset _: Int = 0
    ) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest
        var predicates: [NSPredicate] = []

        if !text.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR tDescription CONTAINS[cd] %@", text, text)
            predicates.append(searchPredicate)
        }

        if !tags.isEmpty {
            let tagsPredicate = NSPredicate(format: "ANY tags IN %@", tags)
            predicates.append(tagsPredicate)
        }

        if !types.isEmpty {
            let typesPredicate = NSPredicate(format: "type IN %@", types.map(\.rawValue))
            predicates.append(typesPredicate)
        }

        if !status.isEmpty {
            let statusPredicate = NSPredicate(format: "status IN %@", status.map(\.rawValue))
            predicates.append(statusPredicate)
        }

        if let monthly {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: monthly)
            let month = calendar.component(.month, from: monthly)

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            if let startDate = calendar.date(from: components),
               let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)
            {
                let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
                predicates.append(datePredicate)
            }
        }

        if let daily {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: daily)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
            predicates.append(datePredicate)
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        if hourly {
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TaskEntity.startTime, ascending: !ascending),
            ]
        } else {
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TaskEntity.date, ascending: ascending),
            ]
        }

//        request.fetchBatchSize = batchSize
//        request.fetchOffset = offset
//        request.fetchLimit = batchSize

        return request
    }

    static func fetchTasksForToday(batchSize: Int = 20, offset: Int = 0) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false),
        ]
        request.fetchBatchSize = batchSize
        request.fetchOffset = offset
        request.fetchLimit = batchSize

        return request
    }

    static func fetchTaskCountGroupedByStatus() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        request.resultType = .dictionaryResultType

        let countExpression = NSExpressionDescription()
        countExpression.name = "count"
        countExpression.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "status")])
        countExpression.expressionResultType = .integer32AttributeType

        request.propertiesToGroupBy = ["status"]
        request.propertiesToFetch = ["status", countExpression]

        return request
    }

    static func fetchRequestForChartData(for startDate: Date, endDate: Date) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest

        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)

        return request
    }

    static func fetchTasks(with filter: SearchFilter, batchSize: Int = 20, offset: Int = 0) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest
        var predicates: [NSPredicate] = []

        if !filter.searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR tDescription CONTAINS[cd] %@", filter.searchText, filter.searchText)
            predicates.append(searchPredicate)
        }

        if !filter.sortByTags.isEmpty {
            let tagsPredicate = NSPredicate(format: "ANY tags IN %@", filter.sortByTags)
            predicates.append(tagsPredicate)
        }

        if !filter.sortByType.isEmpty {
            let typesPredicate = NSPredicate(format: "type IN %@", filter.sortByType.map(\.rawValue))
            predicates.append(typesPredicate)
        }

        if let status = filter.status {
            let statusPredicate = NSPredicate(format: "status == %@", status.rawValue)
            predicates.append(statusPredicate)
        }

        if filter.isMonthly {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: filter.date)
            let month = calendar.component(.month, from: filter.date)

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            if let startDate = calendar.date(from: components),
               let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)
            {
                let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
                predicates.append(datePredicate)
            }
        } else {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: filter.date)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
            predicates.append(datePredicate)
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        if filter.sortByDate == .newest {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)]
        } else {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: true)]
        }

        request.fetchBatchSize = batchSize
        request.fetchOffset = offset
        request.fetchLimit = batchSize

        return request
    }
}

extension TaskEntity {
    static func preview(count: Int, in context: NSManagedObjectContext = CoreDataStack.shared.viewContext) -> [TaskEntity] {
        var tasks: [TaskEntity] = []
        let tag1 = TagEntity(context: context)
        tag1.name = "Home"
        tag1.color = "#11b9ac"
        let tag2 = TagEntity(context: context)
        tag2.name = "Office"
        tag2.color = "#ec0661"

        for i in 0 ..< count {
            let task = TaskEntity(context: context)
            task.title = "Task \(tasks.count + 1)"
            task.tDescription = "Description \(tasks.count + 1)"
            task.tags = [tag1, tag2]
            task.date = Calendar.current.date(byAdding: .day, value: i, to: .init()) ?? Date()
            task.startTime = Calendar.current.date(byAdding: .hour, value: i, to: .init()) ?? Date()
            task.endTime = Calendar.current.date(byAdding: .hour, value: i * 2, to: .init()) ?? Date()
            tasks.append(task)
        }
        try? context.save()
        return tasks
    }

    static func oneTask() -> TaskEntity {
        let context = CoreDataStack.shared.viewContext
        let tag1 = TagEntity(context: context)
        tag1.name = "Home"
        tag1.color = "#11b9ac"
        let tag2 = TagEntity(context: context)
        tag2.name = "Office"
        tag2.color = "#ec0661"

        let task = TaskEntity(context: context)
        task.title = "Cleaning Clothes"
        task.tDescription = "Clean clothes in the closet."
        task.tags = [tag1, tag2]
        return task
    }
}
