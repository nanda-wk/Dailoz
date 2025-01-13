//
//  TaskRepository.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import Combine
import Foundation

final class TaskRepository {
    private let localDataSource: TaskLocalDataSource

    init(localDataSource: TaskLocalDataSource = TaskLocalDataSource()) {
        self.localDataSource = localDataSource
    }

    func fetchTasks(
        text: String = "",
        tags: [TagEntity] = [],
        types: [TType] = [],
        status: [TStatus] = [],
        monthly: Date? = nil,
        daily: Date? = nil,
        ascending: Bool = false,
        offset: Int = 0
    ) -> [TaskEntity] {
        let tasks = localDataSource.fetchTasks(
            text: text,
            tags: tags,
            types: types,
            status: status,
            monthly: monthly,
            daily: daily,
            ascending: ascending,
            offset: offset
        )
        return tasks
    }

    func fetchTasksCount() -> [TStatus: Int] {
        var taskStatusCounts: [TStatus: Int] = [:]
        guard let result = localDataSource.fetchTaskCount() else {
            return [:]
        }
        for dictionary in result {
            if let statusString = dictionary["status"] as? String,
               let status = TStatus(rawValue: statusString),
               let count = dictionary["count"] as? Int
            {
                taskStatusCounts[status] = count
            }
        }
        return taskStatusCounts
    }

    func fetchTasksGroupedByDate(
        text: String = "",
        tags: [TagEntity] = [],
        types: [TType] = [],
        status: [TStatus] = [],
        monthly: Date? = nil,
        daily: Date? = nil,
        ascending: Bool = false,
        offset: Int = 0,
        lang: AppLanguage = .en_US
    ) -> [String: [TaskEntity]] {
        var result: [String: [TaskEntity]] = [:]
        let tasks = localDataSource.fetchTasks(
            text: text,
            tags: tags,
            types: types,
            status: status,
            monthly: monthly,
            daily: daily,
            ascending: ascending,
            offset: offset
        )
        result = Dictionary(grouping: tasks) { task -> String in
            task.date.format(.ddMMMMyyyy, language: lang)
        }

        return result
    }

    func fetchTasksGroupedByHour(
        text: String = "",
        date: Date? = nil,
        hourly: Bool = false,
        offset: Int = 0,
        lang: AppLanguage = .en_US
    ) -> [String: [TaskEntity]] {
        var result: [String: [TaskEntity]] = [:]
        let tasks = localDataSource.fetchTasks(
            text: text,
            daily: date,
            hourly: hourly,
            offset: offset
        )
        let calendar = Calendar.current
        result = Dictionary(grouping: tasks) { task -> String in
            let startOfHour = calendar.dateInterval(of: .hour, for: task.startTime)?.start
            return startOfHour?.format(.HHmm, language: lang) ?? task.startTime.format(.HHmm, language: lang)
        }

        return result
    }

    func fetchTasksForWeeklyChart(for date: Date, lang: AppLanguage) -> [ChartData] {
        var results: [ChartData] = []
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            return results
        }
        guard let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            return results
        }

        guard let resultDict = localDataSource.fetchTaskForWeeklyChart(for: startOfWeek, endDate: endOfWeek) else {
            return results
        }

        var groupedData: [Weekday: TaskTypeCounts] = [:]
        for day in Weekday.allCases {
            groupedData[day] = TaskTypeCounts()
        }

        for task in resultDict {
            let weekday = calendar.component(.weekday, from: task.date)
            let weekdayName = calendar.weekdaySymbols[weekday - 1]

            if let weekdayName = Weekday(rawValue: weekdayName) {
                switch task.typeEnum {
                case .personal:
                    groupedData[weekdayName]?.personal += 1
                case .tPrivate:
                    groupedData[weekdayName]?.tPrivate += 1
                case .secret:
                    groupedData[weekdayName]?.secret += 1
                }
            }
        }

        for weekday in Weekday.allCases {
            if let typecounts = groupedData[weekday] {
                let day = weekday.localized(lang)
                let appendCount = [
                    ChartData(date: day, type: .personal, count: typecounts.personal),
                    ChartData(date: day, type: .secret, count: typecounts.secret),
                    ChartData(date: day, type: .tPrivate, count: typecounts.tPrivate),
                ]
                results.append(contentsOf: appendCount)
            }
        }

        return results
    }

    func fetchTasksForPrevious12Days(from date: Date, lang: AppLanguage) -> [ChartData] {
        var results: [ChartData] = []
        let calendar = Calendar.current

        let previous12Days = (0 ..< 12).compactMap { calendar.date(byAdding: .day, value: -$0, to: date) }

        var groupedData: [String: TaskTypeCounts] = [:]
        for day in previous12Days {
            let formatedDay = day.format(.dd, language: lang)
            groupedData[formatedDay] = TaskTypeCounts()
        }

        guard let tasks = localDataSource.fetchTaskForWeeklyChart(for: previous12Days.last!, endDate: previous12Days.first!) else {
            return results
        }

        for task in tasks {
            switch task.typeEnum {
            case .personal:
                groupedData[task.date.format(.dd, language: lang)]?.personal += 1
            case .tPrivate:
                groupedData[task.date.format(.dd, language: lang)]?.tPrivate += 1
            case .secret:
                groupedData[task.date.format(.dd, language: lang)]?.secret += 1
            }
        }

        for date in previous12Days.sorted() {
            if let typeCounts = groupedData[date.format(.dd, language: lang)] {
                let formattedDate = date.format(.dd, language: lang)
                let appendData = [
                    ChartData(date: formattedDate, type: .personal, count: typeCounts.personal),
                    ChartData(date: formattedDate, type: .secret, count: typeCounts.secret),
                    ChartData(date: formattedDate, type: .tPrivate, count: typeCounts.tPrivate),
                ]
                results.append(contentsOf: appendData)
            }
        }

        return results
    }

    func create(
        title: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        description: String,
        type: TType,
        tags: Set<TagEntity> = [],
        status: TStatus = .pending
    ) -> TaskEntity? {
        let createdTask = localDataSource.create(
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            description: description,
            type: type,
            tags: tags,
            status: status
        )
        guard let createdTask else { return nil }
        scheduleNotification(for: createdTask)
        return createdTask
    }

    func updateTask(task: TaskEntity) -> TaskEntity? {
        let updatedTask = localDataSource.update(task: task)
        guard let updatedTask else { return nil }
        updateNotification(for: updatedTask)
        return updatedTask
    }

    func deleteTask(task: TaskEntity) {
        removeNotification(for: task)
        localDataSource.delete(task: task)
    }

    private enum Weekday: String, CaseIterable {
        case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

        func localized(_ lang: AppLanguage) -> String {
            switch self {
            case .Sunday:
                lang == .en_US ? "Sun" : "နွေ"
            case .Monday:
                lang == .en_US ? "Mon" : "လာ"
            case .Tuesday:
                lang == .en_US ? "Tue" : "ဂါ"
            case .Wednesday:
                lang == .en_US ? "Wed" : "ဟူး"
            case .Thursday:
                lang == .en_US ? "Thu" : "တေး"
            case .Friday:
                lang == .en_US ? "Fri" : "ကြာ"
            case .Saturday:
                lang == .en_US ? "Sat" : "နေ"
            }
        }
    }

    private struct TaskTypeCounts {
        var personal: Int = 0
        var secret: Int = 0
        var tPrivate: Int = 0
    }
}
