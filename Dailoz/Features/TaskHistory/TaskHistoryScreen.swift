//
//  TaskHistoryScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-07.
//

import SwiftUI

struct TaskHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var taskRepository: TaskRepository
    @FetchRequest(fetchRequest: Tag.all()) private var tags

    let status: TStatus

    // MARK: - View UI State

    @State private var navTitle = "Task Overview"
    @State private var showDatePicker = false
    @State private var showFilterSheet = true
    @State private var contentUnavailabelText = ""

    @State private var searchFilter = SearchFilter()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                SearchBar(searchFilter: $searchFilter)

                DateFilterButton()

                TaskListByDate()
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 40)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            navTitle = status.rawValue
            searchFilter.status = status
            switch status {
            case .completed:
                contentUnavailabelText = "No completed tasks yet. Keep going!"
            case .pending:
                contentUnavailabelText = "No pending tasks right now. Great work!"
            case .canceled:
                contentUnavailabelText = "No canceled tasks yet. Keep going!"
            case .onGoing:
                contentUnavailabelText = "No on going tasks yet. Keep going!"
            }

            taskRepository.fetchGroupedTaskByDate(with: searchFilter)
        }
        .onChange(of: searchFilter) {
            taskRepository.fetchGroupedTaskByDate(with: searchFilter, offset: 0)
        }
        .onChange(of: refreshManager.refreshId) {
            taskRepository.fetchGroupedTaskByDate(with: searchFilter)
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

extension TaskHistoryScreen {
    private func DateFilterButton() -> some View {
        Button {
            searchFilter.isMonthly = true
            showDatePicker.toggle()
        } label: {
            Label("\(searchFilter.date.format(.MMMMyyyy))", systemImage: "calendar")
                .font(.robotoM(22))
                .tint(.textPrimary)
        }
        .padding()
        .sheet(isPresented: $showDatePicker) {
            DatePicker("", selection: $searchFilter.date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .tint(.royalBlue)
        }
    }

    // TODO: - Need to implement lazy loading tasks from Core Data.
    @ViewBuilder
    private func TaskListByDate() -> some View {
        let taskListIsEmpty = taskRepository.groupTasks.isEmpty
        if !taskListIsEmpty {
            ForEach(taskRepository.groupTasks.sorted(by: {
                if searchFilter.sortByDate == .newest {
                    $0.key > $1.key
                } else {
                    $0.key < $1.key
                }
            }), id: \.key) { key, value in
                TaskListCell(date: key, tasks: value)
            }
            .overlay {
                if taskRepository.isFetching {
                    ProgressView()
                        .foregroundStyle(.royalBlue)
                }
            }
        } else {
            ContentUnavailableView(contentUnavailabelText, systemImage: "text.page.badge.magnifyingglass")
                .foregroundStyle(.textPrimary)
        }
    }

    private func TaskListCell(date: String, tasks: [DTask]) -> some View {
        Section {
            GeometryReader { geometry in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(tasks) { task in
                            TaskCard(task: task)
                                .frame(width: geometry.size.width * 0.5)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(.horizontal, 20, for: .scrollContent)
            }
            .frame(height: 130)
        } header: {
            Text(date)
                .font(.robotoR(16))
                .foregroundStyle(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}

#Preview {
    NavigationStack {
        TaskHistoryScreen(status: .pending)
            .previewEnvironment()
    }
}
