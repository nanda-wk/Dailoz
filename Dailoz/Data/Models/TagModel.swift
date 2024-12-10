//
//  TagModel.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import SwiftUI

struct TagModel: Identifiable {
    var id: UUID
    var name: String
    var color: Color

    init(id: UUID, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

extension TagModel {
    static func fromEntity(_ entity: TagEntity) -> TagModel {
        TagModel(id: entity.id, name: entity.name, color: Color(hex: entity.color))
    }
}
