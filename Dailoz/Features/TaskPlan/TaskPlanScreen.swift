//
//  TaskPlanScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct TaskPlanScreen: View {
    
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTiem = Date()
    @State private var description = ""
    @State private var type = ""
    @State private var tags: [String] = []



    var body: some View {
        Form {
            
        }

    }
}

#Preview {
    TaskPlanScreen()
}
