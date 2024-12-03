//
//  View+Preview.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

@MainActor
extension View {
    func previewEnvironment() -> some View {
        DTask.preview(count: 7)
        Tag.preview(count: 5)
        return environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
            .environmentObject(TaskRepository())
            .environmentObject(TagRepository())
    }
}
