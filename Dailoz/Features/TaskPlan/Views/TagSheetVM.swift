//
//  TagSheetVM.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import SwiftUI

@MainActor
final class TagSheetVM: ObservableObject {
    // MARK: - View UI State

    @Published private(set) var navTitle = "Add Tag"
    @Published private(set) var btnText = "Save"
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

    private var tag: TagModel?

    private let tagRepository: TagRepository

    init(tag: TagModel?, tagRepository: TagRepository = TagRepository()) {
        if let tag {
            navTitle = "Edit Tag"
            btnText = "Update"
            name = tag.name
            color = tag.color
        }

        self.tag = tag
        self.tagRepository = tagRepository
    }

    func save() {
        if var tagToUpdate = tag {
            tagToUpdate.name = name
            tagToUpdate.color = color
            _ = tagRepository.updateTag(id: tagToUpdate.id, with: tagToUpdate)
        } else {
            let newTag = TagModel(id: .init(), name: name, color: color)
            _ = tagRepository.createTag(with: newTag)
        }
    }

    func validate() {
        isDisabled = name.isEmpty
    }
}
