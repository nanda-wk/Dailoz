//
//  TaskPlanScreenVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Foundation

@MainActor
final class TaskPlanScreenVM: ObservableObject {
    @Published private(set) var tasks: [TaskModel] = []
    @Published private(set) var tags: [TagModel] = []

    @Published private(set) var navTitle = "Add Task"
    @Published private(set) var btnText = "Create"
    @Published private(set) var isDisabled = true

//    private let taskRepository: TaskRepository
    private let tagRepository: TagRepository

    private var task: TaskModel?

    init(task: TaskModel?, tagRepository: TagRepository = TagRepository()) {
        if task != nil {
            navTitle = "Edit Task"
            btnText = "Update"

            // MARK: - Setup binding.
        }

        self.task = task
//        self.taskRepository = taskRepository
        self.tagRepository = tagRepository
        fetchTags()
    }

    func fetchTags() {
        tags = tagRepository.fetchTags()
    }

    func deleteTag(for tag: TagModel) {
        _ = tagRepository.deleteTag(id: tag.id)
        fetchTags()
    }
}
