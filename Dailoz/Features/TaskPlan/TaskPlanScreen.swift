//
//  TaskPlanScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TaskPlanScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var refreshManager: UIStateManager
    @FetchRequest(fetchRequest: TagEntity.all()) private var tagList
    @StateObject private var vm: TaskPlanScreenVM

    // MARK: - View UI State

    @State private var showDatePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var columns: [GridItem] = .init(repeating: .init(.flexible()), count: 4)
    @State private var showTagSheet = false
    @State private var showNewTagButton = true

    @State private var tagToUpdate: TagEntity?
    @State private var isRefreshed = false

    private let coreDataStack = CoreDataStack.shared

    init(task: TaskEntity? = nil) {
        _vm = StateObject(wrappedValue: TaskPlanScreenVM(task: task))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                CustomTextField(title: "Title", text: $vm.title)

                CustomDatePicker()

                TimeSection()

                CustomTextField(title: "Description", text: $vm.description)

                TypeSection()

                TagsSection()

                Spacer()

                Button {
                    vm.save()
                    refreshManager.triggerRefresh()
                    dismiss()
                } label: {
                    AppButton(title: vm.btnText, isDisabled: vm.isDisabled)
                }
                .disabled(vm.isDisabled)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    refreshManager.triggerRefresh()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(.royalBlue)
                }
            }
        }
        .navigationTitle(vm.navTitle)
        .navigationBarTitleDisplayMode(.inline)
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
                Text(vm.date.format(.dMMMMyyyy))
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
                    DatePicker("", selection: $vm.date, displayedComponents: .date)
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
                        Text(vm.startTime.format(.hhmm_a))
                            .font(.robotoM(18))
                            .foregroundStyle(.textPrimary)
                        Divider()
                    }
                }
                .sheet(isPresented: $showStartTimePicker) {
                    DatePicker("", selection: $vm.startTime, displayedComponents: .hourAndMinute)
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
                        Text(vm.endTime.format(.hhmm_a))
                            .font(.robotoM(18))
                            .foregroundStyle(.textPrimary)
                        Divider()
                    }
                }
                .sheet(isPresented: $showEndTimePicker) {
                    DatePicker("", selection: $vm.endTime, displayedComponents: .hourAndMinute)
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

            Picker("", selection: $vm.type) {
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
                ForEach(tagList) { tag in
                    ChipView(name: tag.name, color: tag.getColor, isSelected: vm.isSelectedTag(tag))
                        .onTapGesture {
                            vm.toggleTagSelection(tag)
                        }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                tagToUpdate = tag
                                showTagSheet.toggle()
                            }

                            Button("Delete", systemImage: "trash", role: .destructive) {
                                vm.deleteTag(for: tag)
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
            tagToUpdate = nil
        } content: {
            TagSheet(tag: tagToUpdate)
                .presentationDetents([.fraction(0.4)])
        }
    }
}

#Preview {
    NavigationStack {
        TaskPlanScreen()
            .previewEnvironment()
    }
}
