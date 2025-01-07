//
//  ProfileScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var preferences: UserPreferences

    var body: some View {
        List {
            VStack {
                Image(.avatarDummy)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                Text("Nanda")
                    .font(.robotoB(22))
            }
            .frame(maxWidth: .infinity)

            Picker("Languages", systemImage: "globe", selection: $preferences.appLang) {
                ForEach(AppLanguage.allCases) { lan in
                    Text(lan.title)
                }
            }
            .pickerStyle(.navigationLink)
            .tint(.royalBlue)

            Toggle("Allow Notifications", systemImage: "bell.badge", isOn: $preferences.allowNotification)
                .tint(.royalBlue)
        }
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
            .previewEnvironment()
    }
}
