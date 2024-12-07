//
//  ChipView.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-07.
//

import SwiftUI

struct ChipView: View {
    let name: String
    let color: Color
    let isSelected: Bool
    var body: some View {
        Text(name)
            .font(.robotoR(16))
            .foregroundStyle(isSelected ? .white : color)
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(color.opacity(isSelected ? 1 : 0.2))
            )
    }
}

#Preview {
    ChipView(name: "Tag", color: .royalBlue, isSelected: false)
}
