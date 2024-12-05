//
//  TaskCard.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-04.
//

import SwiftUI

struct TaskCard: View {
    @EnvironmentObject var taskRepository: TaskRepository
    let task: DTask

    @State private var taskToEdit: DTask?

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(task.bgColor)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 3)
                        .foregroundStyle(task.color)
                        .padding(.trailing)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(task.title)
                            .font(.robotoM(18))
                            .foregroundStyle(.textPrimary)

                        Text(task.timeRange)
                            .font(.robotoR(16))
                            .foregroundStyle(.textSecondary)
                    }

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

    private func TagSection() -> some View {
        HStack {
            Spacer()
                .frame(width: 3)
                .padding(.trailing)

            LazyHStack(spacing: 8) {
                ForEach(Array(task.tags)) { tag in
                    TagCard(tag: tag)
                }
            }
        }
    }

    @ViewBuilder
    private func MenuButton() -> some View {
        Menu {
            if task.statusEnum == .onGoing {
                Button("Disable", systemImage: "xmark.square") {}
                    .tint(.black)
            }

            if task.statusEnum == .pending {
                Button("Enable", systemImage: "checkmark.square") {}
            }

            if task.statusEnum != .completed {
                Button("Edit", systemImage: "square.and.pencil") {
                    taskToEdit = task
                }
            }

            if task.statusEnum == .completed || task.statusEnum == .canceled {
                Button("Restore", systemImage: "arrow.up.square") {}
            }

            Button("Delete", systemImage: "trash", role: .destructive) {
                taskRepository.delete(task)
            }
        } label: {
            Image(systemName: "ellipsis")
                .scaledToFit()
                .frame(width: 24, height: 24)
                .tint(.black)
        }
        .fullScreenCover(item: $taskToEdit) {
            taskToEdit = nil
        } content: { _ in
            NavigationStack {
                TaskPlanScreen(task: $taskToEdit)
            }
        }
    }
}

#Preview {
    TaskCard(task: DTask.oneTask())
        .previewEnvironment()
}
