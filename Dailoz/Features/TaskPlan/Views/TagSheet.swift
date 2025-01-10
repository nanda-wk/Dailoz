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

    let tag: TagEntity?

    init(tag: TagEntity?) {
        self.tag = tag
        _vm = StateObject(wrappedValue: TagSheetVM(tag: tag))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Features.TaskPlan.Views.TagSheet.Name")
                        .font(.robotoM(16))
                        .foregroundStyle(.textSecondary)

                    TextField("Features.TaskPlan.Views.TagSheet.TagName", text: $vm.name)
                        .font(.robotoM(18))
                        .foregroundStyle(.textPrimary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)

                    Divider()
                }

                ColorPicker(selection: $vm.color) {
                    Text("Features.TaskPlan.Views.TagSheet.TagColor")
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
                    Button("Dailoz.Cancel.Button") {
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
