//
//  ProfileScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct ProfileScreen: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var preferences: UserPreferences
    @State private var showNameEditor = false

    var body: some View {
        List {
            VStack {
                Image(.avatarDummy)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                Text(preferences.userName)
                    .font(.robotoB(22))
            }
            .frame(maxWidth: .infinity)

            Section {
                Button {
                    showNameEditor.toggle()
                } label: {
                    Text("Update profile")
                }

            } header: {
                Text("Profile")
            }

            Section {
                Picker("Languages", systemImage: "globe", selection: $preferences.appLang) {
                    ForEach(AppLanguage.allCases) { lan in
                        Text(lan.title)
                    }
                }
                .pickerStyle(.navigationLink)
                .tint(.royalBlue)

                Toggle("Allow Notifications", systemImage: "bell.badge", isOn: $preferences.allowNotification)
                    .tint(.royalBlue)
            } header: {
                Text("Setting")
            }
        }
        .foregroundStyle(.textPrimary)
        .fullScreenCover(isPresented: $showNameEditor) {
            NameRegisterScreen()
        }
        .onChange(of: preferences.allowNotification) {
            if preferences.allowNotification {
                scheduleNotificationsForAllTasks(context: moc)
            } else {
                disableAllNotifications()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
            .previewEnvironment()
    }
}
