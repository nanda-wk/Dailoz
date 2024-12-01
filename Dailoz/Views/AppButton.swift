//
//  AppButton.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import Foundation
import SwiftUI

struct AppButton: View {
    var title: String
    var height: CGFloat = 60
    var cornerRadius: CGFloat = 14
    var isDisabled = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isDisabled ? .gray : .royalBlue)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .shadow(color: .royalBlue.opacity(0.4), radius: 10, x: 0, y: 5)
                )

            Text(title)
                .font(.robotoB(18))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    AppButton(title: "Button")
}
