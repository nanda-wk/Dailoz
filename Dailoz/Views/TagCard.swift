//
//  TagCard.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TagCard: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.robotoM(12))
            .foregroundStyle(.royalBlue)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.royalBlue.opacity(0.5), in: RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    TagCard(name: "Hello")
}
