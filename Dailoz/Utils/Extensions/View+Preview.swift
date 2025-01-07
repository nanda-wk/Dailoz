//
//  View+Preview.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

@MainActor
extension View {
    func previewEnvironment(taskCount _: Int = 7, tagCount _: Int = 5) -> some View {
        environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
            .environmentObject(UIStateManager())
            .environmentObject(UserPreferences())
    }
}
