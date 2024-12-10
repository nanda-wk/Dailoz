//
//  TagBadge.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TagBadge: View {
    let tag: TagEntity
    private var color: Color {
        Color(hex: tag.color)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(color.opacity(0.3))

            Text(tag.name)
                .font(.robotoM(12))
                .foregroundStyle(color)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
        }
        .frame(width: 60, height: 24)
    }
}

#Preview {
    TagBadge(tag: TagEntity.previewTags()[1])
}
