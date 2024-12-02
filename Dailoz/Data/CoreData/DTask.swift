//
//  DTask.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import CoreData
import Foundation

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
        return "\(start)-\(end)"
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
    static func preview(count: Int, in context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        var tasks: [DTask] = []
        for _ in 0 ..< count {
            let task = DTask(context: context)
            task.title = "Task \(tasks.count + 1)"
            task.tDescription = "Description \(tasks.count + 1)"
            tasks.append(task)
        }
        try? context.save()
    }
}
