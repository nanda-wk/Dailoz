//
//  TaskModel.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-10.
//

import CoreData

struct TaskModel: Identifiable {
    var id: UUID
    var title: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var description: String
    var type: TType
    var status: TStatus
    var tags: [TagModel]
}
