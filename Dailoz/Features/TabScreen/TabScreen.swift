//
//  TabScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TabScreen: View {
    @EnvironmentObject var uiStateManager: UIStateManager
    @State private var selected: TabItem = .home
    @State private var showTaskPlanScreen = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selected {
                case .home:
                    NavigationStack {
                        HomeScreen()
                    }
                case .task:
                    NavigationStack {
                        TaskOverviewScreen()
                    }
                case .activity:
                    NavigationStack {
                        ActivityScreen()
                    }
                case .profile:
                    NavigationStack {
                        ProfileScreen()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Spacer()
                    .frame(height: 40)
            }

            if uiStateManager.showTabBar {
                CustomTabBar()
            }
        }
        .onAppear {
            uiStateManager.showTabBar = true
        }
        .fullScreenCover(isPresented: $showTaskPlanScreen) {
            NavigationStack {
                TaskPlanScreen()
            }
        }
    }

    private func NativeTabView() -> some View {
        TabView(selection: $selected) {
            NavigationStack {
                HomeScreen()
            }
            .tag(TabItem.home)

            NavigationStack {
                TaskOverviewScreen()
            }
            .tag(TabItem.task)

            NavigationStack {
                ActivityScreen()
            }
            .tag(TabItem.activity)

            NavigationStack {
                ProfileScreen()
            }
            .tag(TabItem.profile)
        }
    }

    private func CustomTabBar() -> some View {
        ZStack {
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        selected = .home
                    }
                } label: {
                    CustomTabItem(tab: .home)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut) {
                        selected = .task
                    }
                } label: {
                    CustomTabItem(tab: .task)
                }

                Spacer()

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

                Spacer()

                Button {
                    withAnimation(.easeInOut) {
                        selected = .activity
                    }
                } label: {
                    CustomTabItem(tab: .activity)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut) {
                        selected = .profile
                    }
                } label: {
                    CustomTabItem(tab: .profile)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 76)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private func CustomTabItem(tab: TabItem) -> some View {
        let isActive = tab == selected
        VStack {
            Image(isActive ? tab.selectedIcon : tab.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)

            Circle()
                .fill(isActive ? .royalBlue : .white)
                .frame(width: 6)
        }
        .padding()
    }
}

enum TabItem: String, Identifiable {
    case home, task, activity, profile

    var id: String {
        rawValue
    }

    var icon: ImageResource {
        switch self {
        case .home:
            .home
        case .task:
            .task
        case .activity:
            .activity
        case .profile:
            .profile
        }
    }

    var selectedIcon: ImageResource {
        switch self {
        case .home:
            .homeFill
        case .task:
            .taskFill
        case .activity:
            .activityFill
        case .profile:
            .profileFill
        }
    }
}

#Preview {
    TabScreen()
        .previewEnvironment()
}
