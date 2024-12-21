//
//  TagLocalDataSource.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Foundation

final class TagLocalDataSource {
    private let stack = CoreDataStack.shared
    private lazy var moc = stack.viewContext

    func fetchTags() -> [TagEntity] {
        let fetchRequest = TagEntity.all()
        do {
            let fetchedTags = try moc.fetch(fetchRequest)
            return fetchedTags
        } catch {
            print("Failed to fetch tags: \(error)")
        }
        return []
    }

    func create(name: String, color: String) -> TagEntity? {
        let entity = TagEntity(context: moc)
        entity.name = name
        entity.color = color
        guard let context = entity.managedObjectContext else { return nil }
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to create tag: \(error)")
        }
        return entity
    }

    func update(tag: TagEntity) -> TagEntity? {
        guard let context = tag.managedObjectContext else {
            return nil
        }
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to update tag: \(error)")
        }
        return nil
    }

    func delete(tag: TagEntity) {
        guard let context = tag.managedObjectContext else {
            return
        }
        do {
            try stack.delete(tag, in: context)
        } catch {
            print("Failed to delete tag: \(error)")
        }
    }
}
