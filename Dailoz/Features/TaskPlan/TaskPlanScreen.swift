//
//  TaskPlanScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TaskPlanScreen: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @FetchRequest(fetchRequest: Tag.all()) private var tagList

    @State private var title = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var description = ""
    @State private var type = TType.personal
    @State private var tags: Set<Tag> = []

    // MARK: - View UI State

    @State private var isValid = false
    @State private var showDatePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    @State private var columns: [GridItem] = .init(repeating: .init(.flexible()), count: 4)
    @State private var showTagSheet = false
    @State private var showNewTagButton = true

    @State private var tagToUpdate: Tag?

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

                Button {} label: {
                    AppButton(title: "Create", isDisabled: !isValid)
                }
                .disabled(!isValid)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(.royalBlue)
                }
            }
        }
        .navigationTitle("Add Task")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
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
                ForEach(tagList) { tag in
                    TagCapsule(tag)
                        .onTapGesture {
                            toggleTagSelection(tag)
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
        } content: {
            TagSheet(tag: $tagToUpdate)
                .presentationDetents([.fraction(0.4)])
        }
    }

    @ViewBuilder
    private func TagCapsule(_ tag: Tag) -> some View {
        let isSelected = isSelectedTag(tag)
        Text(tag.name)
            .font(.robotoR(16))
            .foregroundStyle(isSelected ? .white : Color(hex: tag.color))
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color(hex: tag.color).opacity(isSelected ? 1 : 0.2))
            )
            .contextMenu {
                Button("Edit", systemImage: "pencil") {
                    tagToUpdate = tag
                    showTagSheet.toggle()
                }

                Button("Delete", systemImage: "trash", role: .destructive) {
                    try? coreDataStack.delete(tag, in: moc)
                    checkTagsCount()
                }
            }
    }
}

extension TaskPlanScreen {
    private func checkTagsCount() {
        showNewTagButton = tagList.count < 8
    }

    private func toggleTagSelection(_ tag: Tag) {
        if !tags.insert(tag).inserted {
            tags.remove(tag)
        }
    }

    private func isSelectedTag(_ tag: Tag) -> Bool {
        tags.contains(tag)
    }
}

#Preview {
    NavigationStack {
        TaskPlanScreen()
            .previewEnvironment()
    }
}
