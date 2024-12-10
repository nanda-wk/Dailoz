//
//  TaskPlanScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TaskPlanScreen: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var taskRepository: TaskRepositoryOld
    @EnvironmentObject private var tagRepository: TagRepositoryOld
    @EnvironmentObject private var refreshManager: RefreshManager
    @FetchRequest(fetchRequest: TagEntity.all()) private var tagList

    @StateObject private var vm = TaskPlanScreenVM(task: nil)

    @Binding var task: TaskEntity?

    @State private var title = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var description = ""
    @State private var type = TType.personal
    @State private var tags: Set<TagEntity> = []

    // MARK: - View UI State

    @State private var navTitle = "Add Task"
    @State private var btnText = "Create"
    @State private var isValid = false
    @State private var showDatePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var columns: [GridItem] = .init(repeating: .init(.flexible()), count: 4)
    @State private var showTagSheet = false
    @State private var showNewTagButton = true

    @State private var taskToSave: TaskEntity!
    @State private var tagToUpdate: TagModel?
    @State private var isRefreshed = false

    private let coreDataStack = CoreDataStack.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                CustomTextField(title: "Title", text: $title)
                    .onChange(of: title) {
                        isValid = !title.isEmpty
                    }

                CustomDatePicker()

                TimeSection()

                CustomTextField(title: "Description", text: $description)

                TypeSection()

                TagsSection()

                Spacer()

                Button {
                    saveTask()
                    dismiss()
                    taskRepository.fetchTaskCount()
                    refreshManager.triggerRefresh()
                } label: {
                    AppButton(title: btnText, isDisabled: !isValid)
                }
                .disabled(!isValid)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                    if isRefreshed {
                        refreshManager.triggerRefresh()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(.royalBlue)
                }
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupBinding()
            checkTagsCount()
        }
    }
}

extension TaskPlanScreen {
    private func CustomTextField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.robotoM(16))
                .foregroundStyle(.textSecondary)

            TextField("", text: text)
                .font(.robotoM(18))
                .foregroundStyle(.textPrimary)
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled(true)

            Divider()
        }
    }

    private func CustomDatePicker() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Date")
                .font(.robotoM(16))
                .foregroundStyle(.textSecondary)

            HStack {
                Text(date.format(.dMMMMyyyy))
                    .font(.robotoM(18))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Button {
                    showDatePicker.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.royalBlue.opacity(0.7))
                }
                .sheet(isPresented: $showDatePicker) {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .tint(.royalBlue)
                }
            }

            Divider()
        }
    }

    private func TimeSection() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Time")
                .font(.robotoM(16))
                .foregroundStyle(.textSecondary)

            HStack {
                Button {
                    showStartTimePicker.toggle()
                } label: {
                    VStack {
                        Text(startTime.format(.hhmm_a))
                            .font(.robotoM(18))
                            .foregroundStyle(.textPrimary)
                        Divider()
                    }
                }
                .sheet(isPresented: $showStartTimePicker) {
                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .tint(.royalBlue)
                        .padding()
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }

                Spacer()
                    .frame(width: 18)

                Button {
                    showEndTimePicker.toggle()
                } label: {
                    VStack {
                        Text(endTime.format(.hhmm_a))
                            .font(.robotoM(18))
                            .foregroundStyle(.textPrimary)
                        Divider()
                    }
                }
                .sheet(isPresented: $showEndTimePicker) {
                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .tint(.royalBlue)
                        .padding()
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }

    private func TypeSection() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Type")
                .font(.robotoM(16))
                .foregroundStyle(.textSecondary)

            Picker("", selection: $type) {
                ForEach(TType.allCases) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private func TagsSection() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tags")
                .font(.robotoM(16))
                .foregroundStyle(.textSecondary)

            LazyVGrid(columns: columns) {
                ForEach(vm.tags) { tag in
                    ChipView(name: tag.name, color: tag.color, isSelected: false)
//                        .onTapGesture {
//                            toggleTagSelection(tag)
//                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                tagToUpdate = tag
                                showTagSheet.toggle()
                            }

                            Button("Delete", systemImage: "trash", role: .destructive) {
                                vm.deleteTag(for: tag)
                                checkTagsCount()
                                isRefreshed = true
                            }
                        }
                }
            }

            if showNewTagButton {
                Button {
                    tagToUpdate = nil
                    showTagSheet.toggle()
                } label: {
                    Text("+ Add new tag")
                        .font(.robotoM(14))
                        .foregroundStyle(.royalBlue)
                        .frame(height: 30)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .sheet(isPresented: $showTagSheet) {
            checkTagsCount()
            vm.fetchTags()
        } content: {
            TagSheet(tag: tagToUpdate)
                .presentationDetents([.fraction(0.4)])
        }
    }
}

extension TaskPlanScreen {
    private func setupBinding() {
        if let task {
            navTitle = "Update Task"
            btnText = "Update"

            title = task.title
            date = task.date
            startTime = task.startTime
            endTime = task.endTime
            description = task.tDescription
            type = task.typeEnum
            tags = task.tags
        }
    }

    private func checkTagsCount() {
        showNewTagButton = tagList.count < 8
    }

    private func toggleTagSelection(_ tag: TagEntity) {
        if !tags.insert(tag).inserted {
            tags.remove(tag)
        }
    }

    private func isSelectedTag(_ tag: TagEntity) -> Bool {
        tags.contains(tag)
    }

    private func saveTask() {
        taskToSave = task ?? TaskEntity(context: moc)
        taskToSave.title = title
        taskToSave.date = date
        taskToSave.startTime = startTime
        taskToSave.endTime = endTime
        taskToSave.tDescription = description
        taskToSave.type = type.rawValue
        taskToSave.tags = tags.filter { moc.registeredObject(for: $0.objectID) != nil }
        taskRepository.save(taskToSave)
    }
}

#Preview {
    NavigationStack {
        TaskPlanScreen(task: .constant(nil))
            .previewEnvironment()
    }
}
