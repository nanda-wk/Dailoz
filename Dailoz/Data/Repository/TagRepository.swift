//
//  TagRepository.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import SwiftUI

final class TagRepository {
    private let localDataSource: TagLocalDataSource

    init(localDataSource: TagLocalDataSource = TagLocalDataSource()) {
        self.localDataSource = localDataSource
    }

    func fetchTags() -> [TagEntity] {
        let tags = localDataSource.fetchTags()
        return tags
    }

    func createTag(name: String, color: Color) -> TagEntity? {
        let createdTag = localDataSource.create(name: name, color: color.hexString)
        return createdTag
    }

    func updateTag(tag: TagEntity) -> TagEntity? {
        let updatedTag = localDataSource.update(tag: tag)
        return updatedTag
    }

    func deleteTag(tag: TagEntity) {
        localDataSource.delete(tag: tag)
    }
}
