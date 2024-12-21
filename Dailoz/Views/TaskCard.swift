//
//  TaskCard.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-04.
//

import SwiftUI

struct TaskCard: View {
    @EnvironmentObject var refreshManager: UIStateManager
    let task: TaskEntity
    var onDelete: () -> Void
    var onEnable: (() -> Void)? = nil
    var onDisable: (() -> Void)? = nil
    var onRestore: (() -> Void)? = nil

    @State private var showTaskPlanScreen = false
    @State private var showingAlert = false

    var body: some View {
        if let _ = task.managedObjectContext {
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

            Text(task.timeRange)
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
            if task.statusEnum == .onGoing, let onDisable {
                Button("Disable", systemImage: "xmark.square") {
                    onDisable()
                }
                .tint(.black)
            }

            if task.statusEnum == .pending, let onEnable {
                Button("Enable", systemImage: "checkmark.square") {
                    onEnable()
                }
            }

            if task.statusEnum != .completed {
                Button("Edit", systemImage: "square.and.pencil") {
                    showTaskPlanScreen.toggle()
                }
            }

            if task.statusEnum == .completed || task.statusEnum == .canceled, let onRestore {
                Button("Restore", systemImage: "arrow.up.square") {
                    onRestore()
                }
            }

            Button("Delete", systemImage: "trash", role: .destructive) {
                showingAlert.toggle()
            }

        } label: {
            Image(systemName: "ellipsis")
                .scaledToFit()
                .frame(width: 24, height: 24)
                .tint(.black)
        }
        .fullScreenCover(isPresented: $showTaskPlanScreen) {
            NavigationStack {
                TaskPlanScreen(task: task)
            }
        }
        .alert("Are you sure?", isPresented: $showingAlert) {
            Button("Delete", role: .destructive) {
                onDelete()
                refreshManager.triggerRefresh()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    TaskCard(task: TaskEntity.oneTask(), onDelete: { print("delete") })
        .previewEnvironment()
}
