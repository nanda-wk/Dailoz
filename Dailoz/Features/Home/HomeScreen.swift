//
//  HomeScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct HomeScreen: View {
    @FetchRequest(fetchRequest: DTask.fetchTasksForToday()) var tasks

    @State private var showTaskPlanScreen = false

    @State private var taskToEdit: DTask?

    var body: some View {
        List {
            ForEach(tasks) { task in
                Button {
                    taskToEdit = task
                    showTaskPlanScreen.toggle()
                } label: {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(task.color)
                            )

                        LazyHStack {
                            ForEach(Array(task.tags)) { tag in
                                Text(tag.name)
                                    .foregroundStyle(Color(hex: tag.color))
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Home Screen")
        .fullScreenCover(isPresented: $showTaskPlanScreen) {
            taskToEdit = nil
        } content: {
            NavigationStack {
                TaskPlanScreen(task: $taskToEdit)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
            .previewEnvironment()
    }
}
