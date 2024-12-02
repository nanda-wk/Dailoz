//
//  TagSheet.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

struct TagSheet: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss

    @Binding var tag: Tag?

    @State private var name = ""
    @State private var color = Color(.royalBlue)
    @State private var tagToSave: Tag!

    @State private var title = "Add Tag"
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
            .navigationTitle(title)
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
                        dismiss()
                    }
                    .tint(.royalBlue)
                    .disabled(isDisable)
                }
            }
            .onAppear {
                if let tag {
                    title = "Edit Tag"
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

        try? moc.save()
    }
}

#Preview {
    NavigationStack {
        TagSheet(tag: .constant(nil))
    }
}