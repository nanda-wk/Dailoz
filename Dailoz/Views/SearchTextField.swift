//
//  SearchTextField.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-07.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: "f6f6f6"))
                    .frame(height: 60)

                HStack {
                    Image(systemName: "magnifyingglass")

                    TextField("Dailoz.SearchField.Placeholder", text: $searchText)
                        .font(.robotoR(16))
                        .foregroundStyle(.textPrimary)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled(true)
                }
                .overlay {
                    HStack {
                        Spacer()
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .tint(.gray)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    SearchTextField(searchText: .constant(""))
}
