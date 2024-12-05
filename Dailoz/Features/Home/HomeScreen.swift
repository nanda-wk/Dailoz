//
//  HomeScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @FetchRequest(fetchRequest: DTask.all()) var tasks

    @State private var taskToEdit: DTask?

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(tasks) { task in
                    TaskCard(task: task)
                }
            }
            .padding()
        }
        .id(refreshManager.refreshId)
        .navigationTitle("Home Screen")
//        .fullScreenCover(item: $taskToEdit)  { in
//            NavigationStack {
//                TaskPlanScreen(task: $taskToEdit)
//            }
//        }
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
            .previewEnvironment()
    }
}
