//
//  NameRegisterScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-07.
//

import SwiftUI

struct NameRegisterScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var preferences: UserPreferences

    var body: some View {
        VStack {
            Image(.splash)
                .resizable()
                .scaledToFit()
                .frame(width: 294, height: 294)

            Spacer()

            HStack(alignment: .bottom) {
                Text("Dailoz")
                    .font(.robotoB(34))
                    .foregroundStyle(.royalBlue)

                Circle()
                    .fill(.canceled)
                    .frame(width: 8, height: 8)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 18) {
                Text("What is your name?")
                    .font(.robotoM(16))
                    .foregroundStyle(.textSecondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "f6f6f6"))
                        .frame(height: 60)

                    TextField("", text: $preferences.userName)
                        .font(.robotoM(18))
                        .foregroundStyle(.textPrimary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                        .padding()
                }
            }

            Spacer()

            Button {
                preferences.isFirstLunch = false
                dismiss()
            } label: {
                AppButton(title: "Save", isDisabled: preferences.userName.isEmpty)
            }
            .disabled(preferences.userName.isEmpty)
        }
        .padding()
    }
}

#Preview {
    NameRegisterScreen()
        .previewEnvironment()
}
