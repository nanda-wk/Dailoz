//
//  DailozApp.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI
import UserNotifications

@main
struct DailozApp: App {
    private let coreDataStack = CoreDataStack.shared
    @StateObject private var uiStateManager = UIStateManager()
    @StateObject private var preferences = UserPreferences()
    @State private var showLaunchScreen = true

    init() {
        setupAppLanguage()
        UITabBar.appearance().standardAppearance.configureWithTransparentBackground()

        let segmentedAppearance = UISegmentedControl.appearance()
        segmentedAppearance.backgroundColor = .royalBlue.withAlphaComponent(0.15)
        segmentedAppearance.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segmentedAppearance.selectedSegmentTintColor = .royalBlue
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showLaunchScreen {
                    LaunchScreen()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showLaunchScreen = false
                            }
                        }
                } else {
                    TabScreen()
                }
            }
            .environment(\.locale, .init(identifier: preferences.appLang.rawValue))
            .environment(\.managedObjectContext, coreDataStack.viewContext)
            .environmentObject(uiStateManager)
            .environmentObject(preferences)
            .onAppear {
                if preferences.isFirstLunch, !preferences.allowNotification {
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
                            if let error {
                                print("Error requesting notification permissions: \(error.localizedDescription)")
                                preferences.allowNotification = false
                            }
                            preferences.allowNotification = true
                        }
                    }
                }
            }
        }
    }
}

extension DailozApp {
    private func setupAppLanguage() {
        let systemLanguage = Locale.preferredLanguages.first
        guard let systemLanguage, let appLanguage = AppLanguage(rawValue: systemLanguage) else { return }
        preferences.appLang = appLanguage
    }
}
