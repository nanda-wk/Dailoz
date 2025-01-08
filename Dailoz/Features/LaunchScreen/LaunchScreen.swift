//
//  LaunchScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-07.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        VStack {
            Spacer()

            Image(.splash)
                .resizable()
                .scaledToFit()
                .frame(width: 294, height: 294)

            Spacer()

            VStack(spacing: 30) {
                HStack(alignment: .bottom) {
                    Text("Dailoz")
                        .font(.robotoB(34))
                        .foregroundStyle(.royalBlue)

                    Circle()
                        .fill(.canceled)
                        .frame(width: 8, height: 8)
                }

                Text("Plan what you will do to be more organized for\n today, tomorrow and beyond")
                    .font(.robotoR(16))
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }
}

#Preview {
    LaunchScreen()
}
