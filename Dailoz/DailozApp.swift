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
        }
    }
}
