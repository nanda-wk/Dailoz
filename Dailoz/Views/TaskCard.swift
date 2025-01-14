//
//  TaskCard.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-04.
//

import SwiftUI

struct TaskCard: View {
    @EnvironmentObject var preferences: UserPreferences
    @EnvironmentObject var refreshManager: UIStateManager
    let task: TaskEntity
    private let vm = TaskCardVM()

    @State private var showTaskPlanScreen = false
    @State private var showingAlert = false

    var body: some View {
        if let _ = task.managedObjectContext {
            NavigationLink {
                TaskDetailScreen(task: task)
            } label: {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(task.bgColor)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            HeaderSection()

                            Spacer()

                            MenuButton()
                                .rotationEffect(.degrees(90))
                                .offset(y: -14)
                        }

                        TagSection()
                    }
                    .padding()
                }
                .frame(height: 120)
            }
            .fullScreenCover(isPresented: $showTaskPlanScreen) {
                NavigationStack {
                    TaskPlanScreen(task: task)
                }
            }
        }
    }

    @ViewBuilder
    private func HeaderSection() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 3)
            .foregroundStyle(task.color)
            .padding(.trailing)

        VStack(alignment: .leading, spacing: 10) {
            Text(task.title)
                .font(.robotoM(18))
                .foregroundStyle(.textPrimary)

            Text(task.timeRange(preferences.appLang))
                .font(.robotoR(16))
                .foregroundStyle(.textSecondary)
        }
    }

    private func TagSection() -> some View {
        HStack {
            Spacer()
                .frame(width: 3)
                .padding(.trailing)

            LazyHStack(spacing: 8) {
                ForEach(Array(task.tags)) { tag in
                    TagBadge(tag: tag)
                }
            }
        }
    }

    @ViewBuilder
    private func MenuButton() -> some View {
        Menu {
            if task.statusEnum != .onGoing {
                Button("Dailoz.OnGoing.Button", systemImage: "rhombus.fill") {
                    vm.ongoing(task)
                    refreshManager.triggerRefresh()
                }
                .tint(.black)
            }

            if task.statusEnum != .completed {
                Button("Dailoz.Completed.Button", systemImage: "checkmark.seal") {
                    vm.onCompleted(task)
                    refreshManager.triggerRefresh()
                }
            }

            if task.statusEnum != .completed {
                Button("Dailoz.Edit.Button", systemImage: "square.and.pencil") {
                    showTaskPlanScreen.toggle()
                }
            }

            if task.statusEnum != .canceled {
                Button("Dailoz.Cancel.Button", systemImage: "xmark.seal") {
                    vm.onCanceled(task)
                    refreshManager.triggerRefresh()
                }
            }

            Button("Dailoz.Delete.Button", systemImage: "trash", role: .destructive) {
                showingAlert.toggle()
            }

        } label: {
            Image(systemName: "ellipsis")
                .scaledToFit()
                .frame(width: 24, height: 24)
                .tint(.black)
        }
        .alert("Dailoz.Alert.Title", isPresented: $showingAlert) {
            Button("Dailoz.Delete.Button", role: .destructive) {
                vm.onDelete(task)
                refreshManager.triggerRefresh()
            }
            Button("Dailoz.Cancel.Button", role: .cancel) {}
        }
    }
}

private final class TaskCardVM {
    let taskRepository: TaskRepository
    init(taskRepository: TaskRepository = TaskRepository()) {
        self.taskRepository = taskRepository
    }

    func onDelete(_ task: TaskEntity) {
        taskRepository.deleteTask(task: task)
    }

    func onCompleted(_ task: TaskEntity) {
        task.status = TStatus.completed.rawValue
        _ = taskRepository.updateTask(task: task)
    }

    func onCanceled(_ task: TaskEntity) {
        task.status = TStatus.canceled.rawValue
        _ = taskRepository.updateTask(task: task)
    }

    func ongoing(_ task: TaskEntity) {
        task.status = TStatus.onGoing.rawValue
        _ = taskRepository.updateTask(task: task)
    }
}

#Preview {
    NavigationStack {
        TaskCard(task: TaskEntity.oneTask())
            .previewEnvironment()
    }
}
