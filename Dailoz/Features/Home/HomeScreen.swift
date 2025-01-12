//
//  HomeScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var uiStateManager: UIStateManager
    @EnvironmentObject var preferences: UserPreferences
    @StateObject var vm = HomeScreenVM()
    @AppStorage("selectedTab") var selected: TabItem = .home

    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
//                #if targetEnvironment(simulator)
//                    Button("Add 100 Tasks") {
//                        TaskEntity.makeDummy()
//                    }
//                #endif
                NavBarSection()

                HeroSection()

                TodayTaskSection()
            }
            .padding()
        }
        .id(uiStateManager.refreshId)
        .scrollIndicators(.hidden)
        .onAppear {
            vm.fetchTask()
        }
        .onChange(of: uiStateManager.refreshId) {
            vm.fetchTask()
        }
        .fullScreenCover(isPresented: $preferences.isFirstLunch) {
            NameRegisterScreen()
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 80)
        }
    }
}

extension HomeScreen {
    private func NavBarSection() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Features.Home.HomeScreen.Greeing.Name \(preferences.userName)")
                    .font(.robotoB(30))
                    .foregroundStyle(.textPrimary)

                Text("Features.Home.HomeScreen.Greeing.Description")
                    .font(.robotoR(16))
                    .foregroundStyle(.gray)
            }

            Spacer()

            Button {
                selected = .profile
            } label: {
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
            Text("Features.Home.HomeScreen.MyTask.Title")
                .font(.robotoB(26))
                .foregroundStyle(.textPrimary)

            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    NavigationLink {
                        TaskHistoryScreen(status: .completed)
                    } label: {
                        HeroCard(count: vm.completedCount, icon: Image(.iMac), title: "Completed", background: .completed)
                    }

                    NavigationLink {
                        TaskHistoryScreen(status: .canceled)
                    } label: {
                        HeroCard(count: vm.canceledCount, icon: Image(systemName: "xmark.square"), title: "Canceled", background: .canceled, foreground: .white, isSmallIcon: true)
                    }
                }

                VStack(spacing: 20) {
                    NavigationLink {
                        TaskHistoryScreen(status: .pending)
                    } label: {
                        HeroCard(count: vm.pendingCount, icon: Image(systemName: "clock"), title: "Pending", background: .pending, foreground: .white, isSmallIcon: true)
                    }

                    NavigationLink {
                        TaskHistoryScreen(status: .onGoing)
                    } label: {
                        HeroCard(count: vm.onGoingCount, icon: Image(.folder), title: "On Going", background: .ongoing)
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

                    Text("Features.Home.HomeScreen.HeroCard \(count)")
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
                Text("Dailoz.TodayTask.Title")
                    .font(.robotoB(26))
                    .foregroundStyle(.textPrimary)

                Spacer()

                if !vm.tasksIsEmpty {
                    NavigationLink {
                        TaskListScreen(navTitle: "Today Tasks")
                    } label: {
                        Text("Dailoz.ViewAll.Button")
                            .font(.robotoR(14))
                            .foregroundStyle(.textSecondary)
                    }
                }
            }

            Spacer()
                .frame(height: 10)

            if !vm.tasksIsEmpty {
                ForEach(vm.tasks.prefix(5)) { task in
                    TaskCard(task: task)
                }
            } else {
                ContentUnavailableView("Features.Home.HomeScreen.EmptyList.Description", systemImage: "text.page.badge.magnifyingglass")
                    .foregroundStyle(.textPrimary)
            }
        }
        .animation(.easeIn(duration: 0.3), value: vm.tasks.count)
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
            .previewEnvironment()
    }
}
