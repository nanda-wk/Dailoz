//
//  HomeScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var taskRepository: TaskRepositoryOld

    @State private var taskListIsEmpty = false

    @State private var taskToEdit: TaskEntity?

    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
                NavBarSection()

                HeroSection()

                TodayTaskSection()
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 40)
        }
        .onAppear {
            taskRepository.fetchTaskCount()
            taskRepository.fetchTasks(with: .init())
            taskListIsEmpty = taskRepository.tasks.isEmpty
        }
        .onChange(of: refreshManager.refreshId) {
            taskRepository.fetchTasks(with: .init(), offset: 0)
        }
    }

    private func NavBarSection() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hi, Nanda")
                    .font(.robotoB(30))
                    .foregroundStyle(.textPrimary)

                Text("Let’s make this day productive")
                    .font(.robotoR(16))
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {} label: {
                Image(.avatarDummy)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        }
    }

    private func HeroSection() -> some View {
        VStack(alignment: .leading) {
            Text("My Task")
                .font(.robotoB(26))
                .foregroundStyle(.textPrimary)

            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    NavigationLink {
                        TaskHistoryScreen(status: .completed)
                    } label: {
                        HeroCard(count: taskRepository.taskCountWithStatus[.completed] ?? 0, icon: Image(.iMac), title: "Completed", background: .completed)
                    }

                    NavigationLink {
                        TaskHistoryScreen(status: .canceled)
                    } label: {
                        HeroCard(count: taskRepository.taskCountWithStatus[.canceled] ?? 0, icon: Image(systemName: "xmark.square"), title: "Canceled", background: .canceled, foreground: .white, isSmallIcon: true)
                    }
                }

                VStack(spacing: 20) {
                    NavigationLink {
                        TaskHistoryScreen(status: .pending)
                    } label: {
                        HeroCard(count: taskRepository.taskCountWithStatus[.pending] ?? 0, icon: Image(systemName: "clock"), title: "Pending", background: .pending, foreground: .white, isSmallIcon: true)
                    }

                    NavigationLink {
                        TaskHistoryScreen(status: .onGoing)
                    } label: {
                        HeroCard(count: taskRepository.taskCountWithStatus[.onGoing] ?? 0, icon: Image(.folder), title: "On Going", background: .ongoing)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func HeroCard(
        count: Int,
        icon: Image,
        title: String,
        background: Color,
        foreground: Color = .black,
        isSmallIcon: Bool = false
    ) -> some View {
        let iconSize: CGFloat = isSmallIcon ? 40 : 90
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [background], startPoint: .bottomLeading, endPoint: .topTrailing)
                    )
                    .shadow(color: background.opacity(0.4), radius: 10, x: 0, y: 5)

                VStack(alignment: .leading, spacing: 10) {
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)

                    if isSmallIcon {
                        Spacer()
                            .frame(height: 6)
                    }

                    Text(title)
                        .font(.robotoM(18))

                    Text("^[\(count) Task](inflect: true)")
                        .font(.robotoR(16))
                }
                .padding()
            }

            Image(systemName: "arrow.forward")
                .padding()
        }
        .foregroundStyle(foreground)
    }

    @ViewBuilder
    private func TodayTaskSection() -> some View {
        LazyVStack(spacing: 16) {
            HStack {
                Text("Today Task")
                    .font(.robotoB(26))
                    .foregroundStyle(.textPrimary)

                Spacer()

                if !taskListIsEmpty {
                    NavigationLink {
                        TaskListScreen(navTitle: "Today Tasks")
                    } label: {
                        Text("View all")
                            .font(.robotoR(14))
                            .foregroundStyle(.textSecondary)
                    }
                }
            }

            Spacer()
                .frame(height: 10)

            if !taskListIsEmpty {
                ForEach(taskRepository.tasks.prefix(5)) { task in
                    TaskCard(task: task)
                }
                .overlay {
                    if taskRepository.isFetching {
                        ProgressView()
                            .foregroundStyle(.royalBlue)
                    }
                }
            } else {
                ContentUnavailableView("No tasks scheduled for today.", systemImage: "text.page.badge.magnifyingglass")
                    .foregroundStyle(.textPrimary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
            .previewEnvironment(taskCount: 0)
    }
}
