//
//  TagSheetVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import SwiftUI

final class TagSheetVM: ObservableObject {
    // MARK: - View UI State

    @Published private(set) var navTitle: LocalizedStringKey = "Features.TaskPlan.Views.TagSheet.Title.Add"
    @Published private(set) var btnText: LocalizedStringKey = "Features.TaskPlan.TaskPlanScreen.Button.Save"
    @Published private(set) var isDisabled = true

    // MARK: - View Data State

    @Published var name: String = "" {
        didSet {
            validate()
        }
    }

    @Published var color: Color = .royalBlue {
        didSet {
            validate()
        }
    }

    private var tag: TagEntity?

    private let tagRepository: TagRepository

    init(tag: TagEntity?, tagRepository: TagRepository = TagRepository()) {
        if let tag {
            navTitle = "Features.TaskPlan.Views.TagSheet.Title.Edit"
            btnText = "Features.TaskPlan.TaskPlanScreen.Button.Update"
            name = tag.name
            color = Color(hex: tag.color)
        }

        self.tag = tag
        self.tagRepository = tagRepository
    }

    func save() {
        if let tagToUpdate = tag {
            tagToUpdate.name = name
            tagToUpdate.color = color.hexString
            _ = tagRepository.updateTag(tag: tagToUpdate)
        } else {
            _ = tagRepository.createTag(name: name, color: color)
        }
    }

    func validate() {
        isDisabled = name.isEmpty
    }
}
