//
//  TagRepository.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import Foundation

@MainActor
final class TagRepository: ObservableObject {
    private let stack = CoreDataStack.shared
    private lazy var moc = stack.viewContext

    func save(_ tag: Tag) {
        let context = tag.managedObjectContext ?? moc
        do {
            try stack.persist(in: context)
        } catch {
            print("Failed to save tag: \(error)")
        }
    }

    func delete(_ tag: Tag) {
        let context = tag.managedObjectContext ?? moc
        do {
            try stack.delete(tag, in: context)
        } catch {
            print("Failed to delete tag: \(error)")
        }
    }
}
