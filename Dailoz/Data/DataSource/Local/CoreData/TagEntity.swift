//
//  TagEntity.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import CoreData
import Foundation
import SwiftUI

final class TagEntity: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var color: String
    @NSManaged var tasks: Set<TaskEntity>
}

extension TagEntity {
    static var tagFetchRequest: NSFetchRequest<TagEntity> {
        NSFetchRequest(entityName: "TagEntity")
    }

    static func all() -> NSFetchRequest<TagEntity> {
        let request: NSFetchRequest<TagEntity> = tagFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TagEntity.name, ascending: false),
        ]
        return request
    }

    static func fetchByID(_ id: UUID) -> NSFetchRequest<TagEntity> {
        let request = tagFetchRequest
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.sortDescriptors = []
        return request
    }
}

extension TagEntity {
    func fromModel(_ model: TagModel) {
        id = model.id
        name = model.name
        color = model.color.hexString
    }

    func toModel() -> TagModel {
        TagModel(id: id, name: name, color: Color(hex: color))
    }
}

extension TagEntity {
    static func preview(count: Int, in context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        var tags: [TagEntity] = []
        let dummyTags = [
            "Home",
            "Office",
            "Work",
            "Personal",
            "Family",
            "Urgent",
            "Shopping",
            "Errands",
            "Fitness",
            "Health",
            "Travel",
            "Study",
            "Finances",
            "Projects",
            "Meetings",
            "Ideas",
            "Hobbies",
            "Birthdays",
            "Vacations",
            "Groceries",
            "Chores",
            "Deadlines",
            "Events",
            "Social",
            "Calls",
            "Emails",
            "Weekend",
            "Priority",
            "Inspiration",
        ]

        for _ in 0 ..< count {
            let tag = TagEntity(context: context)
            tag.name = dummyTags.randomElement()!
            tag.color = String(format: "#%06X", Int.random(in: 0 ... 0xFFFFFF))
            tags.append(tag)
        }
        try? context.save()
    }

    static func previewTags() -> [TagEntity] {
        let context = CoreDataStack.shared.viewContext
        let tag1 = TagEntity(context: context)
        tag1.name = "Home"
        tag1.color = "8F99EB"
        let tag2 = TagEntity(context: context)
        tag2.name = "Social Media"
        tag2.color = "7EC8E7"
        return [tag1, tag2]
    }
}
