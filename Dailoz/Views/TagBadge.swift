//
//  TagBadge.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TagBadge: View {
    let tag: Tag
    private var color: Color {
        Color(hex: tag.color)
    }

    var body: some View {
        Text(tag.name)
            .font(.robotoM(12))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(color.opacity(0.3), in: RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    TagBadge(tag: Tag.previewTags()[0])
}
