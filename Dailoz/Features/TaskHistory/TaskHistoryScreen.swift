//
//  TaskHistoryScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-07.
//

import SwiftUI

struct TaskHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var preferences: UserPreferences
    @EnvironmentObject var uiStateManager: UIStateManager
    @FetchRequest(fetchRequest: TagEntity.all()) private var tags

    @StateObject var vm = TaskHistoryScreenVM()

    let status: TStatus

    // MARK: - View UI State

    @State private var navTitle = ""
    @State private var showDatePicker = false
    @State private var showFilterSheet = true
    @State private var contentUnavailabelText: LocalizedStringKey = ""

    init(status: TStatus) {
        self.status = status
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                SearchBar(searchFilter: $vm.searchFilter)

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
            uiStateManager.showTabBar = false
            navTitle = status.rawValue
            vm.searchFilter.status = status
            switch status {
            case .completed:
                contentUnavailabelText = "Dailoz.ContentUnavailable.Completed"
            case .pending:
                contentUnavailabelText = "Dailoz.ContentUnavailable.Pending"
            case .canceled:
                contentUnavailabelText = "Dailoz.ContentUnavailable.Canceled"
            case .onGoing:
                contentUnavailabelText = "Dailoz.ContentUnavailable.OnGoing"
            }

            vm.fetchTasks(offset: 0, lang: preferences.appLang)
        }
        .onChange(of: vm.searchFilter) {
            vm.fetchTasks(offset: 0, lang: preferences.appLang)
        }
        .onChange(of: uiStateManager.refreshId) {
            vm.fetchTasks(offset: 0, lang: preferences.appLang)
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

extension TaskHistoryScreen {
    private func DateFilterButton() -> some View {
        Button {
            showDatePicker.toggle()
        } label: {
            Label("Dailoz.Feature.Date.Localized \(vm.searchFilter.date.format(.MMMMyyyy, language: preferences.appLang))", systemImage: "calendar")
                .font(.robotoM(22))
                .tint(.textPrimary)
        }
        .padding()
        .sheet(isPresented: $showDatePicker) {
            DatePicker("", selection: $vm.searchFilter.date, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .tint(.royalBlue)
        }
    }

    @ViewBuilder
    private func TaskListByDate() -> some View {
        let taskListIsEmpty = vm.tasks.isEmpty
        if !taskListIsEmpty {
            ForEach(vm.tasks.sorted(by: {
                if vm.searchFilter.sortByDate == .newest {
                    $0.key > $1.key
                } else {
                    $0.key < $1.key
                }
            }), id: \.key) { key, value in
                TaskListCell(date: key, tasks: value)
            }
            .overlay {
                if vm.isLoading {
                    ProgressView()
                        .foregroundStyle(.royalBlue)
                }
            }
        } else {
            ContentUnavailableView(contentUnavailabelText, systemImage: "text.page.badge.magnifyingglass")
                .foregroundStyle(.textPrimary)
        }
    }

    private func TaskListCell(date: String, tasks: [TaskEntity]) -> some View {
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
                    .animation(.easeIn(duration: 0.3), value: tasks.count)
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
