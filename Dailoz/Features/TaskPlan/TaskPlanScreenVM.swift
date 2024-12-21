//
//  TaskPlanScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Foundation

final class TaskPlanScreenVM: ObservableObject {
    @Published private(set) var navTitle = "Add Task"
    @Published private(set) var btnText = "Create"
    @Published private(set) var isDisabled = true

    @Published var title = "" {
        didSet {
            validate()
        }
    }

    @Published var date = Date()
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var description = ""
    @Published var type = TType.personal
    @Published var tags: Set<TagEntity> = [] {
        didSet {
            validate()
        }
    }

    private var task: TaskEntity?

    private let taskRepository: TaskRepository
    private let tagRepository: TagRepository

    private let stack = CoreDataStack.shared
    private lazy var moc = stack.viewContext

    init(task: TaskEntity?, tagRepository: TagRepository = TagRepository(), taskRepository: TaskRepository = TaskRepository()) {
        if let task {
            navTitle = "Edit Task"
            btnText = "Update"
            isDisabled = false

            // MARK: - Setup binding.

            title = task.title
            date = task.date
            startTime = task.startTime
            endTime = task.endTime
            description = task.tDescription
            type = task.typeEnum
            tags = task.tags
        }

        self.task = task
        self.taskRepository = taskRepository
        self.tagRepository = tagRepository
    }

    func save() {
        if let taskToUpdate = task {
            taskToUpdate.title = title
            taskToUpdate.date = date
            taskToUpdate.startTime = startTime
            taskToUpdate.endTime = endTime
            taskToUpdate.tDescription = description
            taskToUpdate.type = type.rawValue
            taskToUpdate.tags = tags.filter { moc.registeredObject(for: $0.objectID) != nil }

            _ = taskRepository.updateTask(task: taskToUpdate)
        } else {
            _ = taskRepository.create(
                title: title,
                date: date,
                startTime: startTime,
                endTime: endTime,
                description: description,
                type: type,
                tags: tags,
                status: .pending
            )
        }
    }

    func deleteTag(for tag: TagEntity) {
        tagRepository.deleteTag(tag: tag)
    }

    func validate() {
        if !title.isEmpty, !tags.isEmpty {
            isDisabled = false
        }
    }

    func toggleTagSelection(_ tag: TagEntity) {
        if !tags.insert(tag).inserted {
            tags.remove(tag)
        }
    }

    func isSelectedTag(_ tag: TagEntity) -> Bool {
        tags.contains(tag)
    }
}
