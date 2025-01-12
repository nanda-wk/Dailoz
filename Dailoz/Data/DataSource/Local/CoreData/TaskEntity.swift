//
//  TaskEntity.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-02.
//

import CoreData
import Foundation
import SwiftUICore

final class TaskEntity: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var date: Date
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date
    @NSManaged var tDescription: String
    @NSManaged var type: String
    @NSManaged var status: String
    @NSManaged var tags: Set<TagEntity>

    var typeEnum: TType {
        if let type = TType(rawValue: type) {
            type
        } else {
            .personal
        }
    }

    var statusEnum: TStatus {
        if let status = TStatus(rawValue: status) {
            status
        } else {
            .pending
        }
    }

    func timeRange(_ lang: AppLanguage) -> String {
        let start = startTime.format(.HHmm, language: lang)
        let end = endTime.format(.HHmm, language: lang)
        return "\(start) - \(end)"
    }

    var color: Color {
        switch statusEnum {
        case .completed:
            .completed
        case .pending:
            .pending
        case .canceled:
            .canceled
        case .onGoing:
            .ongoing
        }
    }

    var bgColor: Color {
        switch statusEnum {
        case .completed:
            .completedBG
        case .pending:
            .pendingBG
        case .canceled:
            .canceledBG
        case .onGoing:
            .ongoingBG
        }
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(Date(), forKey: "date")
        setPrimitiveValue(Date(), forKey: "startTime")
        setPrimitiveValue(Date(), forKey: "endTime")
        setPrimitiveValue(TType.personal.rawValue, forKey: "type")
        setPrimitiveValue(TStatus.pending.rawValue, forKey: "status")
    }
}

extension TaskEntity {
    static var taskFetchRequest: NSFetchRequest<TaskEntity> {
        NSFetchRequest(entityName: "TaskEntity")
    }

    static func all() -> NSFetchRequest<TaskEntity> {
        let request: NSFetchRequest<TaskEntity> = taskFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false),
        ]
        return request
    }

    static func fetchTasks(
        text: String = "",
        tags: [TagEntity] = [],
        types: [TType] = [],
        status: [TStatus] = [],
        monthly: Date? = nil,
        daily: Date? = nil,
        hourly: Bool = false,
        ascending: Bool = false,
        batchSize _: Int = 20,
        offset _: Int = 0
    ) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest
        var predicates: [NSPredicate] = []

        if !text.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR tDescription CONTAINS[cd] %@", text, text)
            predicates.append(searchPredicate)
        }

        if !tags.isEmpty {
            let tagsPredicate = NSPredicate(format: "ANY tags IN %@", tags)
            predicates.append(tagsPredicate)
        }

        if !types.isEmpty {
            let typesPredicate = NSPredicate(format: "type IN %@", types.map(\.rawValue))
            predicates.append(typesPredicate)
        }

        if !status.isEmpty {
            let statusPredicate = NSPredicate(format: "status IN %@", status.map(\.rawValue))
            predicates.append(statusPredicate)
        }

        if let monthly {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: monthly)
            let month = calendar.component(.month, from: monthly)

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            if let startDate = calendar.date(from: components),
               let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)
            {
                let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
                predicates.append(datePredicate)
            }
        }

        if let daily {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: daily)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
            predicates.append(datePredicate)
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        if hourly {
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TaskEntity.startTime, ascending: !ascending),
            ]
        } else {
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TaskEntity.date, ascending: ascending),
            ]
        }

//        request.fetchBatchSize = batchSize
//        request.fetchOffset = offset
//        request.fetchLimit = batchSize

        return request
    }

    static func fetchTasksForToday(batchSize: Int = 20, offset: Int = 0) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false),
        ]
        request.fetchBatchSize = batchSize
        request.fetchOffset = offset
        request.fetchLimit = batchSize

        return request
    }

    static func fetchTaskCountGroupedByStatus() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        request.resultType = .dictionaryResultType

        let countExpression = NSExpressionDescription()
        countExpression.name = "count"
        countExpression.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "status")])
        countExpression.expressionResultType = .integer32AttributeType

        request.propertiesToGroupBy = ["status"]
        request.propertiesToFetch = ["status", countExpression]

        return request
    }

    static func fetchRequestForChartData(for startDate: Date, endDate: Date) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest

        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)

        return request
    }

    static func fetchTasks(with filter: SearchFilter, batchSize: Int = 20, offset: Int = 0) -> NSFetchRequest<TaskEntity> {
        let request = taskFetchRequest
        var predicates: [NSPredicate] = []

        if !filter.searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR tDescription CONTAINS[cd] %@", filter.searchText, filter.searchText)
            predicates.append(searchPredicate)
        }

        if !filter.sortByTags.isEmpty {
            let tagsPredicate = NSPredicate(format: "ANY tags IN %@", filter.sortByTags)
            predicates.append(tagsPredicate)
        }

        if !filter.sortByType.isEmpty {
            let typesPredicate = NSPredicate(format: "type IN %@", filter.sortByType.map(\.rawValue))
            predicates.append(typesPredicate)
        }

        if let status = filter.status {
            let statusPredicate = NSPredicate(format: "status == %@", status.rawValue)
            predicates.append(statusPredicate)
        }

        if filter.isMonthly {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: filter.date)
            let month = calendar.component(.month, from: filter.date)

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            if let startDate = calendar.date(from: components),
               let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)
            {
                let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
                predicates.append(datePredicate)
            }
        } else {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: filter.date)
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
            let datePredicate = NSPredicate(format: "date >= %@ AND date < %@", startOfToday as NSDate, endOfToday as NSDate)
            predicates.append(datePredicate)
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        if filter.sortByDate == .newest {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)]
        } else {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: true)]
        }

        request.fetchBatchSize = batchSize
        request.fetchOffset = offset
        request.fetchLimit = batchSize

        return request
    }
}

extension TaskEntity {
    static func preview(count: Int, in context: NSManagedObjectContext = CoreDataStack.shared.viewContext) -> [TaskEntity] {
        var tasks: [TaskEntity] = []
        let tags = ["Urgent", "Work", "Health", "Finance"]
        let colors = ["#E74C3C", "#3498DB", "#2ECC71", "#F1C40F"]

//        let tagset = Set(tags.prefix(Int.random(in: 1...tags.count)).map { tagName -> TagEntity in
//            let tag = TagEntity(context: context)
//            tag.name = tagName
//            tag.color = colors.randomElement() ?? "Gray"
//            return tag
//        })

        let tagset = Set(tags.map { tagName -> TagEntity in
            let tag = TagEntity(context: context)
            tag.name = tagName
            tag.color = colors.randomElement() ?? "Gray"
            return tag
        })

        for i in 0 ..< count {
            let task = TaskEntity(context: context)
            task.title = "Task \(tasks.count + 1)"
            task.tDescription = "Description \(tasks.count + 1)"
            task.tags = [tagset.randomElement()!, tagset.randomElement()!]
            task.date = Calendar.current.date(byAdding: .day, value: i, to: .init()) ?? Date()
            task.startTime = Calendar.current.date(byAdding: .hour, value: i, to: .init()) ?? Date()
            task.endTime = Calendar.current.date(byAdding: .hour, value: i * 2, to: .init()) ?? Date()
            tasks.append(task)
        }
        try? context.save()
        return tasks
    }

    static func oneTask(type: TType = .personal, status: TStatus = .pending) -> TaskEntity {
        let context = CoreDataStack.shared.viewContext
        let tag1 = TagEntity(context: context)
        tag1.name = "Home"
        tag1.color = "#11b9ac"
        let tag2 = TagEntity(context: context)
        tag2.name = "Office"
        tag2.color = "#ec0661"

        let task = TaskEntity(context: context)
        task.title = "Cleaning ClothesCleaning Clothes"
        task.tDescription = "Clean clothes in the closet."
        task.tags = [tag1, tag2]
        task.type = type.rawValue
        task.status = status.rawValue
        return task
    }

    static func makeDummy(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        let calendar = Calendar.current
        let repo = TagRepository()

        let taskTitlesAndDescriptions: [String: [(title: String, description: String)]] = [
            "Personal": [
                ("Read a Self-Help Book", "Spend 30 minutes reading a book that inspires growth."),
                ("Practice Daily Affirmations", "Write or repeat three positive affirmations."),
                ("Meditate for 10 Minutes", "Relax and clear your mind to reduce stress."),
                ("Plan Your Week", "Create a weekly schedule with clear goals."),
                ("Write in Your Journal", "Reflect on your day's events and emotions."),
                ("Run 3 Miles", "Build stamina by jogging or running outdoors."),
                ("Morning Yoga", "Start your day with a refreshing 20-minute yoga session."),
                ("Go for a Nature Walk", "Enjoy a peaceful walk in a nearby park or forest."),
                ("Declutter Your Workspace", "Organize your desk for better productivity."),
                ("Track Your Daily Habits", "Use a tracker to monitor water intake, sleep, or exercise."),
                ("Set Monthly Goals", "Write down your main objectives for this month."),
                ("Cook a New Recipe", "Try your hand at cooking something new."),
                ("Hydrate Properly", "Drink at least 8 glasses of water today."),
                ("Stretch for 15 Minutes", "Perform light stretches to ease tension."),
                ("Learn a New Skill", "Spend an hour learning a new skill online."),
                ("Read Fiction", "Escape into a fictional world by reading a novel."),
                ("Organize Your Closet", "Sort and arrange your clothing items neatly."),
                ("Plan a Personal Project", "Sketch out ideas for a creative or personal project."),
                ("Reflect on Gratitude", "Write down three things you're grateful for."),
                ("Take a Day Off", "Allow yourself a full day of rest and relaxation."),
            ],
            "Private": [
                ("Plan Your Week", "Create a weekly schedule with goals."),
                ("Declutter Your Desk", "Organize your workspace for better focus."),
                ("Organize Your Files", "Sort and back up your digital documents."),
                ("Draft a Personal Letter", "Write a heartfelt letter to a loved one."),
                ("Review Monthly Expenses", "Analyze your spending for the past month."),
                ("Backup Your Data", "Ensure all your important files are securely backed up."),
                ("Create a Vision Board", "Design a visual representation of your goals."),
                ("Write Down Future Plans", "Sketch out plans for the next 5 years."),
                ("Set Up a Study Corner", "Arrange a dedicated study or work area."),
                ("Take a Tech-Free Hour", "Spend an hour without using any gadgets."),
                ("Sort Old Photos", "Organize and relive old photo memories."),
                ("Learn a New Language", "Spend 30 minutes on a language learning app."),
                ("Read a Motivational Blog", "Find and read a blog that inspires personal growth."),
                ("Organize a Family Album", "Compile photos into a physical or digital album."),
                ("Clean Your Email Inbox", "Delete unwanted emails and organize folders."),
                ("Revisit Childhood Hobbies", "Try something you enjoyed doing as a kid."),
                ("Write a Thank-You Note", "Express gratitude to someone special."),
                ("Do a Social Media Detox", "Take a break from all social media platforms."),
                ("Plan a Staycation", "Organize a relaxing day at home with minimal distractions."),
                ("Do a Digital Detox", "Spend time without any devices for a set period."),
            ],
            "Secret": [
                ("Create a Budget", "Set your financial goals and track expenses."),
                ("Track Your Spending", "Review and categorize your transactions."),
                ("Start an Emergency Fund", "Set aside money for unexpected situations."),
                ("Research Investment Options", "Explore stocks, bonds, or mutual funds."),
                ("Create a Will", "Draft a will to ensure your assets are managed."),
                ("Secure Important Documents", "Organize and store key legal and financial files."),
                ("Set Financial Milestones", "Define major goals, such as buying a home or car."),
                ("Develop a Savings Plan", "Plan how to save for long-term goals."),
                ("Review Your Insurance Policy", "Understand your coverage and update if necessary."),
                ("Automate Bill Payments", "Set up automatic payments for monthly bills."),
                ("Review Tax Deductions", "Look into potential tax benefits you may qualify for."),
                ("Plan a Charitable Donation", "Decide on a cause to contribute to this year."),
                ("Review Your Credit Score", "Check your credit score and find ways to improve it."),
                ("Cancel Unused Subscriptions", "Save money by eliminating unused services."),
                ("Set Up Two-Factor Authentication", "Add an extra layer of security to your accounts."),
                ("Protect Your Privacy Online", "Review your digital footprint and secure accounts."),
                ("Learn About Passive Income", "Research ways to generate income streams."),
                ("Write Down Confidential Thoughts", "Use a journal to record private reflections."),
                ("Reorganize a Secret Folder", "Sort and encrypt sensitive personal documents."),
                ("Plan a Secret Vacation", "Research and plan a getaway just for yourself."),
            ],
        ]

        let statuses: [TStatus] = [.pending, .completed, .canceled, .onGoing]
        let tags = ["Urgent", "Work", "Health", "Finance"]
        let colors = ["#E74C3C", "#3498DB", "#2ECC71", "#F1C40F"]

        // Assign tags.
        let tagSet = kk ? Set(tags.prefix(Int.random(in: 1 ... tags.count)).map { tagName -> TagEntity in
            let tag = TagEntity(context: context)
            tag.name = tagName
            tag.color = colors.randomElement() ?? "Gray"
            return tag
        }) : Set(repo.fetchTags())

        if kk {
            kk.toggle()
        }

        for (type, tasks) in taskTitlesAndDescriptions {
            for i in 0 ..< 20 {
                let task = TaskEntity(context: context)

                let titleDescription = tasks[i % tasks.count]
                task.title = titleDescription.title
                task.tDescription = titleDescription.description
                // Assign a random date in the past or future.
                let randomDayOffset = Int.random(in: -10 ... 10)
                let randomDate = calendar.date(byAdding: .day, value: randomDayOffset, to: Date())!

                // Assign start and end times with 1-3 hours difference.
                let startTime = calendar.date(bySettingHour: Int.random(in: 8 ... 18), minute: 0, second: 0, of: randomDate)!
                let endTime = calendar.date(byAdding: .hour, value: Int.random(in: 1 ... 3), to: startTime)!

                task.date = randomDate
                task.startTime = startTime
                task.endTime = endTime

                task.type = type
                task.status = statuses.randomElement()?.rawValue ?? TStatus.pending.rawValue

                task.tags = Set(Array(tagSet.shuffled().prefix(2)))
            }
        }

        try? context.save()
        print("Dummy Data Created")
    }
}

var kk = true
