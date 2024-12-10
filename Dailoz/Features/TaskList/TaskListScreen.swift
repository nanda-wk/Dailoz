//
//  TaskListScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-08.
//

import SwiftUI

struct TaskListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var taskRepository: TaskRepositoryOld

    let navTitle: String
    @State private var showTaskPlanScreen = false

    @State private var searchFilter = SearchFilter()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                SearchBar(searchFilter: $searchFilter)

                LazyVStack(spacing: 20) {
                    ForEach(taskRepository.tasks) { task in
                        TaskCard(task: task)
                    }

                    if taskRepository.isFetching {
                        ProgressView()
                            .foregroundStyle(.royalBlue)
                            .padding()
                    } else {
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                taskRepository.fetchTasks(with: searchFilter)
                            }
                    }
                }
                .padding()
            }

            Button {
                showTaskPlanScreen.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(.royalBlue)
                        .frame(width: 52)

                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                }
            }
            .padding()
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 40)
        }
        .onAppear {
            taskRepository.fetchTasks(with: searchFilter, offset: 0)
        }
        .onChange(of: searchFilter) {
            taskRepository.fetchTasks(with: searchFilter, offset: 0)
        }
        .fullScreenCover(isPresented: $showTaskPlanScreen) {
            NavigationStack {
                TaskPlanScreen(task: .constant(nil))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .tint(.royalBlue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskListScreen(navTitle: "Task List")
            .previewEnvironment()
    }
}
