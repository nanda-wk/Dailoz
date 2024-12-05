//
//  RefreshManager.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-05.
//

import Foundation

@MainActor
final class RefreshManager: ObservableObject {
    @Published var refreshId = UUID()

    func triggerRefresh() {
        refreshId = UUID()
    }
}
