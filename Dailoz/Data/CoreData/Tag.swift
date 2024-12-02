//
//  Tag.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import CoreData
import Foundation

final class Tag: NSManagedObject, Identifiable {
    @NSManaged var name: String
    @NSManaged var color: String
    @NSManaged var tasks: Set<DTask>
}

extension Tag {
    static var tagFetchRequest: NSFetchRequest<Tag> {
        NSFetchRequest(entityName: "Tag")
    }

    static func all() -> NSFetchRequest<Tag> {
        let request: NSFetchRequest<Tag> = tagFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Tag.name, ascending: false),
        ]
        return request
    }
}

extension Tag {
    static func preview(count: Int, in context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        var tags: [Tag] = []
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
            let tag = Tag(context: context)
            tag.name = dummyTags.randomElement()!
            tag.color = String(format: "#%06X", Int.random(in: 0 ... 0xFFFFFF))
            tags.append(tag)
        }
        try? context.save()
    }
}
