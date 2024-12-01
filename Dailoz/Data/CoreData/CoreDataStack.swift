//
//  CoreDataStack.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import CoreData
import SwiftUICore

final class CoreDataStack {
    static let shared = CoreDataStack()

    private let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "Dailoz")
        if EnvironmentValues.isPreview || Thread.current.isRunningXCTest {
            persistentContainer.persistentStoreDescriptions.first?.url = .init(fileURLWithPath: "/dev/null")
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
    }

    func exisits<T: NSManagedObject>(_ object: T, in context: NSManagedObjectContext) -> T? {
        try? context.existingObject(with: object.objectID) as? T
    }

    func delete(_ object: some NSManagedObject, in context: NSManagedObjectContext) throws {
        if let existingObject = exisits(object, in: context) {
            context.delete(existingObject)
            try context.save()
        }
    }

    func deleteAll(_ type: (some NSManagedObject).Type) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext)
    }

    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

extension EnvironmentValues {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

extension Thread {
    var isRunningXCTest: Bool {
        for key in threadDictionary.allKeys {
            guard let keyAsString = key as? String else {
                continue
            }

            if keyAsString.split(separator: ".").contains("xctest") {
                return true
            }
        }
        return false
    }
}
