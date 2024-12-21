//
//  UIStateManager.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-05.
//

import Foundation
import SwiftUI

@MainActor
final class UIStateManager: ObservableObject {
    @Published var refreshId = UUID()
    @AppStorage("showTabBar") var showTabBar = true

    func triggerRefresh() {
        refreshId = UUID()
    }
}
