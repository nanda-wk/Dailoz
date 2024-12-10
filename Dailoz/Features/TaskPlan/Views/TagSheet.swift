//
//  TagSheet.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import SwiftUI

struct TagSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: TagSheetVM

    let tag: TagModel?

    init(tag: TagModel?) {
        self.tag = tag
        _vm = StateObject(wrappedValue: TagSheetVM(tag: tag))
    }

//    @State private var name = ""
//    @State private var color = Color(.royalBlue)
//    @State private var tagToSave: TagEntity!

//    @State private var navTitle = "Add Tag"
//    @State private var btnText = "Save"
//    @State private var isDisable = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Name")
                        .font(.robotoM(16))
                        .foregroundStyle(.textSecondary)

                    TextField("Tag Name", text: $vm.name)
                        .font(.robotoM(18))
                        .foregroundStyle(.textPrimary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                        .onChange(of: vm.name) {
                            vm.validate()
                        }

                    Divider()
                }

                ColorPicker(selection: $vm.color) {
                    Text("Tag Color")
                        .font(.robotoM(16))
                        .foregroundStyle(.textSecondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(vm.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.royalBlue)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(vm.btnText) {
                        vm.save()
                        dismiss()
                    }
                    .tint(.royalBlue)
                    .disabled(vm.isDisabled)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TagSheet(tag: nil)
    }
}
