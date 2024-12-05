//
//  TagSheet.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

struct TagSheet: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tagRepository: TagRepository

    @Binding var tag: Tag?
    @Binding var isRefreshed: Bool

    @State private var name = ""
    @State private var color = Color(.royalBlue)
    @State private var tagToSave: Tag!

    @State private var navTitle = "Add Tag"
    @State private var btnText = "Save"
    @State private var isDisable = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Name")
                        .font(.robotoM(16))
                        .foregroundStyle(.textSecondary)

                    TextField("Tag Name", text: $name)
                        .font(.robotoM(18))
                        .foregroundStyle(.textPrimary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                        .onChange(of: name) {
                            isDisable = name.isEmpty
                        }

                    Divider()
                }

                ColorPicker(selection: $color) {
                    Text("Tag Color")
                        .font(.robotoM(16))
                        .foregroundStyle(.textSecondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.royalBlue)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(btnText) {
                        saveTag()
                        isRefreshed = true
                        dismiss()
                    }
                    .tint(.royalBlue)
                    .disabled(isDisable)
                }
            }
            .onAppear {
                if let tag {
                    navTitle = "Edit Tag"
                    btnText = "Update"
                    name = tag.name
                    color = Color(hex: tag.color)
                }
            }
        }
    }

    private func saveTag() {
        tagToSave = tag ?? Tag(context: moc)
        tagToSave.name = name
        tagToSave.color = color.hexString

        tagRepository.save(tagToSave)
    }
}

#Preview {
    NavigationStack {
        TagSheet(tag: .constant(nil), isRefreshed: .constant(false))
    }
}
