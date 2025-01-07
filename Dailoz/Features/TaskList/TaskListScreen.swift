//
//  TaskListScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-08.
//

import SwiftUI

struct TaskListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var uiStateManager: UIStateManager

    @StateObject var vm = TaskListScreenVM()

    let navTitle: String

    @State private var showTaskPlanScreen = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                SearchBar(searchFilter: $vm.searchFilter)

                LazyVStack(spacing: 20) {
                    ForEach(vm.tasks) { task in
                        TaskCard(task: task)
                    }
                }
                .padding()
                .animation(.easeIn(duration: 0.3), value: vm.tasks.count)
                .overlay {
                    if vm.isLoading {
                        ProgressView()
                            .foregroundStyle(.royalBlue)
                            .padding()
                    }
                }
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
        .id(uiStateManager.refreshId)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.fetchTasks(offset: 0)
            uiStateManager.showTabBar = false
        }
        .onChange(of: vm.searchFilter) {
            vm.fetchTasks(offset: 0)
        }
        .onChange(of: uiStateManager.refreshId) {
            vm.fetchTasks(offset: 0)
        }
        .fullScreenCover(isPresented: $showTaskPlanScreen) {
            NavigationStack {
                TaskPlanScreen()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    uiStateManager.showTabBar = true
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
