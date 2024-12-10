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

    func save(_ tag: TagEntity) {
        let context = tag.managedObjectContext ?? moc
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to save tag: \(error)")
        }
    }

    func create(with tag: TagModel) -> TagEntity? {
        let entity = TagEntity(context: moc)
        entity.fromModel(tag)
        guard let context = entity.managedObjectContext else { return nil }
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to create tag: \(error)")
        }
        return entity
    }

    func update(id: UUID, with tag: TagModel) -> TagEntity? {
        let fetchRequest = TagEntity.fetchByID(id)
        do {
            if let tagEntity = try moc.fetch(fetchRequest).first {
                tagEntity.fromModel(tag)
                return tagEntity
            }
        } catch {
            print("Failed to update tag with ID<\(id)>: \(error)")
        }
        return nil
    }

    func delete(id: UUID) -> TagModel? {
        let fetchRequest = TagEntity.fetchByID(id)
        do {
            if let tagEntity = try moc.fetch(fetchRequest).first, let context = tagEntity.managedObjectContext {
                let tagModel = tagEntity.toModel()
                try stack.delete(tagEntity, in: context)
                return tagModel
            }
        } catch {
            print("Failed to delete tag with id<\(id)>: \(error)")
        }
        return nil
    }
}
