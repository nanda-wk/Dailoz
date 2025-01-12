//
//  View+Preview.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

@MainActor
extension View {
    func previewEnvironment(
        userName: String = "Nanda",
        language: AppLanguage = .en_US
    ) -> some View {
        TaskEntity.preview(count: 4)
        TaskEntity.preview(count: 4)
        let preferences = UserPreferences()
        preferences.userName = userName
        preferences.appLang = language
        return environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
            .environmentObject(UIStateManager())
            .environmentObject(preferences)
    }
}
