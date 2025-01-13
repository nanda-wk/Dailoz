//
//  TaskDetailScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-09.
//

import SwiftUI

struct TaskDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var preferences: UserPreferences
    @EnvironmentObject var uiStateManager: UIStateManager
    let task: TaskEntity

    let columns: [GridItem] = .init(repeating: .init(.flexible()), count: 4)

    @State private var showTaskPlanScreen = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(task.title)
                        .font(.robotoB(26))
                        .foregroundStyle(.textPrimary)

                    Text(task.type)
                        .font(.robotoR(16))
                        .foregroundStyle(.textSecondary)
                }

                HStack {
                    DetailTimeCard(lang: preferences.appLang)
                    DetailTimeCard(isDate: false, lang: preferences.appLang)
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text("Features.TaskDetail.TaskDetailScreen.Description.Title")
                        .font(.robotoB(22))
                        .foregroundStyle(.textPrimary)

                    Text(task.tDescription)
                        .font(.robotoR(18))
                        .foregroundStyle(.textSecondary)
                }

                TagSection()
            }
            .padding()
        }
        .id(uiStateManager.refreshId)
        .navigationTitle("Features.TaskDetail.TaskDetailScreen.Title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            uiStateManager.showTabBar = false
        }
        .fullScreenCover(isPresented: $showTaskPlanScreen) {
            uiStateManager.triggerRefresh()
        } content: {
            NavigationStack {
                TaskPlanScreen(task: task)
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

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showTaskPlanScreen.toggle()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .tint(.royalBlue)
            }
        }
    }
}

extension TaskDetailScreen {
    @ViewBuilder
    private func DetailTimeCard(isDate: Bool = true, lang: AppLanguage) -> some View {
        let title = isDate ? lang == .en_US ? "Est. Date" : "ခန့်မှန်းရက်" : lang == .en_US ? "Est. Time" : "ခန့်မှန်းချိန်"
        let date = isDate ? task.date.format(.ddMMMMyyyy, language: lang) : task.timeRange(lang)
        let background: Color = switch task.statusEnum {
        case .completed:
            .completed
        case .pending:
            .pending
        case .canceled:
            .canceled
        case .onGoing:
            .ongoing
        }
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(colors: [background], startPoint: .bottomLeading, endPoint: .topTrailing)
                )
                .shadow(color: background.opacity(0.4), radius: 10, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.robotoM(20))
                    .foregroundStyle(task.statusEnum == .completed || task.statusEnum == .onGoing ? .black.opacity(0.5) : .white.opacity(0.5))

                Text(date)
                    .font(.robotoM(20))
                    .foregroundStyle(task.statusEnum == .onGoing ? .black : .white)
            }
            .padding()
        }
    }

    private func TagSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dailoz.Tags.Title")
                .font(.robotoB(22))
                .foregroundStyle(.textPrimary)

            LazyVGrid(columns: columns) {
                ForEach(Array(task.tags)) { tag in
                    ChipView(name: tag.name, color: Color(hex: tag.color), isSelected: false)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailScreen(task: TaskEntity.oneTask(status: .pending))
            .previewEnvironment(language: .my_MM)
    }
}
