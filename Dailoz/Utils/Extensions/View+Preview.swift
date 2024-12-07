//
//  View+Preview.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

@MainActor
extension View {
    func previewEnvironment(taskCount: Int = 7, tagCount: Int = 5) -> some View {
        DTask.preview(count: taskCount)
        Tag.preview(count: tagCount)
        return environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
            .environmentObject(TaskRepository())
            .environmentObject(TagRepository())
            .environmentObject(RefreshManager())
    }
}
