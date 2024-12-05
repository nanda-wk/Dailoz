//
//  DailozApp.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

@main
struct DailozApp: App {
    private let coreDataStack = CoreDataStack.shared
    @StateObject private var taskRepository = TaskRepository()
    @StateObject private var tagRepository = TagRepository()
    @StateObject private var refreshManager = RefreshManager()

    init() {
        UITabBar.appearance().standardAppearance.configureWithTransparentBackground()

        let segmentedAppearance = UISegmentedControl.appearance()
        segmentedAppearance.backgroundColor = .royalBlue.withAlphaComponent(0.15)
        segmentedAppearance.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segmentedAppearance.selectedSegmentTintColor = .royalBlue
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    var body: some Scene {
        WindowGroup {
            TabScreen()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
                .environmentObject(taskRepository)
                .environmentObject(tagRepository)
                .environmentObject(refreshManager)
        }
    }
}
