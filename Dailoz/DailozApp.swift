//
//  DailozApp.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

@main
struct DailozApp: App {

    init() {
        let tabBar = UITabBarAppearance()
        tabBar.configureWithTransparentBackground()
        UITabBar.appearance().standardAppearance = tabBar
    }

    var body: some Scene {
        WindowGroup {
            TabScreen()
        }
    }
}
