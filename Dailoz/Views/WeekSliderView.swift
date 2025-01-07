//
//  WeekSliderView.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-26.
//

import SwiftUI

struct WeekSliderView: View {
    @Binding var currentDate: Date
    @State private var weekSlider: [[Date.Weekday]] = []
    @State private var currentWeekIndex = 1

    @Namespace private var animation

    var body: some View {
        TabView(selection: $currentWeekIndex) {
            ForEach(weekSlider.indices, id: \.self) { index in
                weekView(weekSlider[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear {
            setupInitialWeeks()
        }
        .onChange(of: currentWeekIndex) { _, newIndex in
            handlePagination(for: newIndex)
        }
        .onChange(of: currentDate) { _, _ in
            setupInitialWeeks()
        }
    }

    @ViewBuilder
    private func weekView(_ week: [Date.Weekday]) -> some View {
        HStack {
            ForEach(week) { day in
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSameDate(day.date, currentDate) ? .royalBlue : .clear)

                    VStack(spacing: 10) {
                        Text(day.date.format(.E))
                            .font(.robotoM(18))

                        Text(day.date.format(.dd))
                            .font(.robotoM(16))
                    }
                    .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .textPrimary)
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
    }

    private func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    private func setupInitialWeeks() {
        let currentWeek = currentDate.fetchWeek()
        if let firstDate = currentWeek.first?.date {
            weekSlider.append(firstDate.createPreviousWeek())
        }
        weekSlider.append(currentWeek)
        if let lastDate = currentWeek.last?.date {
            weekSlider.append(lastDate.createNextWeek())
        }
    }

    private func handlePagination(for index: Int) {
        if index == 0, let firstDate = weekSlider.first?.first?.date {
            weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
            DispatchQueue.main.async {
                currentWeekIndex = 1
            }
        } else if index == weekSlider.count - 1, let lastDate = weekSlider.last?.last?.date {
            weekSlider.append(lastDate.createNextWeek())
            DispatchQueue.main.async {
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
}

extension Date {
    struct Weekday: Identifiable {
        var id = UUID()
        var date: Date
    }

    func fetchWeek() -> [Weekday] {
        guard let startOfWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: self)?.start else { return [] }
        return (0 ..< 7).compactMap { offset in
            if let date = Calendar.current.date(byAdding: .day, value: offset, to: startOfWeek) {
                return Weekday(date: date)
            }
            return nil
        }
    }

    func createNextWeek() -> [Weekday] {
        guard let nextWeekDate = Calendar.current.date(byAdding: .day, value: 7, to: self) else { return [] }
        return nextWeekDate.fetchWeek()
    }

    func createPreviousWeek() -> [Weekday] {
        guard let previousWeekDate = Calendar.current.date(byAdding: .day, value: -7, to: self) else { return [] }
        return previousWeekDate.fetchWeek()
    }
}

#Preview {
    @Previewable @State var currentDate: Date = .init()
    WeekSliderView(currentDate: $currentDate)
}
