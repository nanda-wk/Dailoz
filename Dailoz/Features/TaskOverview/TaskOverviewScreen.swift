//
//  TaskOverviewScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-08.
//

import SwiftUI

struct TaskOverviewScreen: View {
    @EnvironmentObject private var taskRepository: TaskRepositoryOld

    @State private var showDatePicker = false

    @State private var searchFilter = SearchFilter()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                SearchTextField(searchText: $searchFilter.searchText)
                    .padding()

                WeekDaySection()

                TaskGroupedHourSection()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 40)
        }
        .onAppear {
            searchFilter.isMonthly = true
            taskRepository.fetchTasks(with: searchFilter, offset: 0)
        }
        .onChange(of: searchFilter) {
            taskRepository.fetchTasks(with: searchFilter, offset: 0)
        }
    }
}

extension TaskOverviewScreen {
    @ViewBuilder
    private func WeekDaySection() -> some View {
        let rdm = Int.random(in: 0 ..< 7)
        VStack {
            HStack {
                Text("Task")
                    .font(.robotoB(26))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Button {
                    showDatePicker.toggle()
                } label: {
                    Label("\(searchFilter.date.format(.MMMMyyyy))", systemImage: "calendar")
                        .font(.robotoR(14))
                        .tint(.textSecondary)
                }
            }

            LazyHStack {
                ForEach(0 ..< 7) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(index == rdm ? .royalBlue : .clear)

                        VStack(spacing: 10) {
                            Text("MO")
                                .font(.robotoM(18))

                            Text("1\(index + 1)")
                                .font(.robotoR(16))
                        }
                        .foregroundStyle(index == rdm ? .white : .textPrimary)
                        .padding(.vertical)
                    }
                    .frame(width: 46)
                }
            }
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

    @ViewBuilder
    private func TaskGroupedHourSection() -> some View {
        let today = if Date().format(.dMMMMyyyy) == searchFilter.date.format(.dMMMMyyyy) {
            "Today"
        } else {
            searchFilter.date.format(.dMMMMyyyy)
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

        ForEach(taskRepository.tasks) { _ in
            TaskList()

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
    }

    @ViewBuilder
    private func TaskList() -> some View {
        Divider()
            .padding(.horizontal)
            .padding(.vertical, 10)

        GeometryReader { geometry in
            HStack {
                Text("07:00")
                    .font(.robotoM(16))
                    .foregroundStyle(.textSecondary)
                    .padding(.leading)
                    .padding(.trailing, 10)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(taskRepository.tasks) { task in
                            TaskCard(task: task) {}
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
