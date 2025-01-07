//
//  TaskOverviewScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-08.
//

import SwiftUI

struct TaskOverviewScreen: View {
    @EnvironmentObject var uiStateManager: UIStateManager
    @StateObject private var vm = TaskOverviewScreenVM()

    @State private var showDatePicker = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                SearchTextField(searchText: $vm.searchFilter.searchText)
                    .padding()

                WeekDaySection()

                TaskGroupedHourSection()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 60)
        }
        .onAppear {
            vm.fetchTasks(offset: 0)
        }
        .onChange(of: vm.searchFilter) {
            vm.fetchTasks(offset: 0)
        }
    }
}

extension TaskOverviewScreen {
    @ViewBuilder
    private func WeekDaySection() -> some View {
        VStack {
            HStack {
                Text("Task")
                    .font(.robotoB(26))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Button {
                    showDatePicker.toggle()
                } label: {
                    Label("\(vm.searchFilter.date.format(.MMMMyyyy))", systemImage: "calendar")
                        .font(.robotoR(14))
                        .tint(.textSecondary)
                }
            }

            WeekSliderView(currentDate: $vm.searchFilter.date)
                .frame(height: 90)
        }
        .padding()
        .sheet(isPresented: $showDatePicker) {
            DatePicker("", selection: $vm.searchFilter.date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .tint(.royalBlue)
        }
    }

    @ViewBuilder
    private func TaskGroupedHourSection() -> some View {
        let today = if Date().format(.dMMMMyyyy) == vm.searchFilter.date.format(.dMMMMyyyy) {
            "Today"
        } else {
            vm.searchFilter.date.format(.dMMMMyyyy)
        }
        HStack {
            Text(today)
                .font(.robotoM(22))
                .foregroundStyle(.textPrimary)

            Spacer()

            Text(Date().format(.hhmm_a))
                .font(.robotoR(16))
                .foregroundStyle(.black)
        }
        .padding(.horizontal)

        if vm.isLoading {
            ProgressView()
                .foregroundStyle(.royalBlue)
                .padding()
        } else {
            ForEach(vm.tasks.sorted(by: { $0.key > $1.key }), id: \.key) { time, tasks in
                TaskList(time: time, tasks: tasks)
            }
        }
    }

    @ViewBuilder
    private func TaskList(time: String, tasks: [TaskEntity]) -> some View {
        Divider()
            .padding(.horizontal)
            .padding(.vertical, 10)

        GeometryReader { geometry in
            HStack {
                Text(time)
                    .font(.robotoM(16))
                    .foregroundStyle(.textSecondary)
                    .padding(.leading)
                    .padding(.trailing, 10)

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
        }
        .frame(height: 130)
    }
}

#Preview {
    NavigationStack {
        TaskOverviewScreen()
            .previewEnvironment()
    }
}
