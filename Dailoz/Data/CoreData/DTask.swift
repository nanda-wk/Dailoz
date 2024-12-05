//
//  DTask.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import CoreData
import Foundation
import SwiftUICore

final class DTask: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var date: Date
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date
    @NSManaged var tDescription: String
    @NSManaged var type: String
    @NSManaged var status: String
    @NSManaged var tags: Set<Tag>

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

extension DTask {
    static var taskFetchRequest: NSFetchRequest<DTask> {
        NSFetchRequest(entityName: "DTask")
    }

    static func all() -> NSFetchRequest<DTask> {
        let request: NSFetchRequest<DTask> = taskFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \DTask.date, ascending: false),
        ]
        return request
    }

    static func fetchTasksForToday() -> NSFetchRequest<DTask> {
        let request = taskFetchRequest
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \DTask.date, ascending: false),
        ]
//        request.returnsObjectsAsFaults = false
        return request
    }

    static func fetchTaskCountGroupedByStatus() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DTask")
        request.resultType = .dictionaryResultType

        let countExpression = NSExpressionDescription()
        countExpression.name = "count"
        countExpression.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "status")])
        countExpression.expressionResultType = .integer32AttributeType

        request.propertiesToGroupBy = ["status"]
        request.propertiesToFetch = ["status", countExpression]

        return request
    }
}

extension DTask {
    static func preview(count: Int, in context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        var tasks: [DTask] = []
        let tag1 = Tag(context: context)
        tag1.name = "Home"
        tag1.color = "#11b9ac"
        let tag2 = Tag(context: context)
        tag2.name = "Office"
        tag2.color = "#ec0661"

        for _ in 0 ..< count {
            let task = DTask(context: context)
            task.title = "Task \(tasks.count + 1)"
            task.tDescription = "Description \(tasks.count + 1)"
            task.tags = [tag1, tag2]
            tasks.append(task)
        }
        try? context.save()
    }

    static func oneTask() -> DTask {
        let context = CoreDataStack.shared.viewContext
        let tag1 = Tag(context: context)
        tag1.name = "Home"
        tag1.color = "#11b9ac"
        let tag2 = Tag(context: context)
        tag2.name = "Office"
        tag2.color = "#ec0661"

        let task = DTask(context: context)
        task.title = "Cleaning Clothes"
        task.tDescription = "Clean clothes in the closet."
        task.tags = [tag1, tag2]
        return task
    }
}
