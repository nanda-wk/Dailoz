//
//  SearchBar.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-07.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchFilter: SearchFilter
    var showFilter = true

    @FetchRequest(fetchRequest: TagEntity.all()) private var tags

    let columns: [GridItem] = .init(repeating: .init(.flexible()), count: 4)
    @State private var showFilterSheet = false

    var body: some View {
        HStack {
            SearchTextField(searchText: $searchFilter.searchText)

            FilterButton()
        }
        .padding()
        .sheet(isPresented: $showFilterSheet) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 26) {
                    SortByTagSection()

                    SortByTypeSection()

                    SortByDateSection()
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset") {
                            var isMonthly = false
                            if searchFilter.isMonthly {
                                isMonthly = true
                            }
                            searchFilter = SearchFilter()
                            searchFilter.isMonthly = isMonthly
                        }
                        .tint(.royalBlue)
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

extension SearchBar {
    private func FilterButton() -> some View {
        Button {
            showFilterSheet.toggle()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .frame(width: 60, height: 60)

                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
        }
        .tint(Color(hex: "f6f6f6"))
    }

    private func SortByTagSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sort by tag")
                .font(.robotoM(16))

            LazyVGrid(columns: columns) {
                ForEach(tags) { tag in

                    ChipView(name: tag.name, color: Color(hex: tag.color), isSelected: isSelected(tag: tag))
                        .onTapGesture {
                            toggleSelection(tag: tag)
                        }
                }
            }
        }
    }

    private func SortByTypeSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sort by type")
                .font(.robotoM(16))

            HStack {
                ForEach(TType.allCases) { type in
                    ChipView(name: type.rawValue, color: type.color, isSelected: isSelected(type: type))
                        .onTapGesture {
                            toggleSelection(type: type)
                        }
                }
            }
        }
    }

    private func SortByDateSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sort by")
                .font(.robotoM(16))

            HStack {
                ForEach(SortByDate.allCases) { value in
                    ChipView(name: value.rawValue, color: .gray, isSelected: isSelected(sort: value))
                        .onTapGesture {
                            searchFilter.sortByDate = value
                        }
                }
            }
        }
    }
}

extension SearchBar {
    private func toggleSelection(tag: TagEntity) {
        if !searchFilter.sortByTags.insert(tag).inserted {
            searchFilter.sortByTags.remove(tag)
        }
    }

    private func isSelected(tag: TagEntity) -> Bool {
        searchFilter.sortByTags.contains(tag)
    }

    private func toggleSelection(type: TType) {
        if !searchFilter.sortByType.insert(type).inserted {
            searchFilter.sortByType.remove(type)
        }
    }

    private func isSelected(type: TType) -> Bool {
        searchFilter.sortByType.contains(type)
    }

    private func isSelected(sort: SortByDate) -> Bool {
        searchFilter.sortByDate == sort
    }
}

#Preview {
    SearchBar(searchFilter: .constant(.init()))
        .previewEnvironment()
}
