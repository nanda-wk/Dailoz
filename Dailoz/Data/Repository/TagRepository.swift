//
//  TagRepository.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Foundation

final class TagRepository {
    private let localDataSource: TagLocalDataSource

    init(localDataSource: TagLocalDataSource = TagLocalDataSource()) {
        self.localDataSource = localDataSource
    }

    func fetchTags() -> [TagModel] {
        let tags = localDataSource.fetchTags()
        return tags.map { TagModel.fromEntity($0) }
    }

    func createTag(with tag: TagModel) -> TagModel? {
        let createdTag = localDataSource.create(with: tag)
        return createdTag?.toModel()
    }

    func updateTag(id: UUID, with tag: TagModel) -> TagModel? {
        let updatedTag = localDataSource.update(id: id, with: tag)
        return updatedTag?.toModel()
    }

    func deleteTag(id: UUID) -> TagModel? {
        let deletedTag = localDataSource.delete(id: id)
        return deletedTag
    }
}
