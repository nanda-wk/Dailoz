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
                    Text("Dailoz.UpdateProfile.Button")
                }

            } header: {
                Text("Features.Profile.ProfileScreen.ProfileHeader.Title")
            }

            Section {
                Picker("Features.Profile.ProfileScreen.Language.Picker", systemImage: "globe", selection: $preferences.appLang) {
                    ForEach(AppLanguage.allCases) { lan in
                        Text(lan.title(preferences.appLang))
                            .tag(lan)
                    }
                }
                .pickerStyle(.navigationLink)
                .tint(.royalBlue)

                Toggle("Features.Profile.ProfileScreen.Notification.Toggle", systemImage: "bell.badge", isOn: $preferences.allowNotification)
                    .tint(.royalBlue)
            } header: {
                Text("Features.Profile.ProfileScreen.SettingHeader.Title")
            }

            Section {
                Link(destination: URL(string: "https://www.sketchappsources.com/free-source/4757-to-do-daily-activities-app-sketch-freebie-resource.html")!) {
                    Text("Design inspiration from **Vektora Studio**")
                }
            } header: {
                Text("Aknowledgement")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 80)
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
        .onChange(of: preferences.appLang) { _, _ in
            preferences.setLanguage()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
            .previewEnvironment()
    }
}
