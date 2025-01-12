//
//  ActivityScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import Charts
import SwiftUI

struct ActivityScreen: View {
    @EnvironmentObject var preferences: UserPreferences
    @EnvironmentObject var uiStateManager: UIStateManager
    @StateObject private var vm = ActivityScreenVM()

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Features.Activity.ActivityScreen.Priority")
                            .font(.robotoB(22))
                            .foregroundStyle(.textPrimary)

                        Spacer()

                        ForEach(TType.allCases) { type in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.footnote)
                                    .foregroundStyle(type.color)

                                Text(type.rawValue)
                                    .font(.robotoR(14))
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                    }

                    Text("Dailoz.TaskPerday.Title")
                        .font(.robotoR(16))
                        .foregroundStyle(.textSecondary)

                    Chart(vm.weklyData) { data in
                        PointMark(
                            x: .value("Dailoz.Date.Title", data.date),
                            y: .value("Dailoz.TaskCount.Title", data.count)
                        )
                        .symbol {
                            Image(systemName: "circle.fill")
                                .scaleEffect(data.count > 5 ? 0.8 : 0.5)
                                .foregroundStyle(data.type.color)
                        }
                    }
                    .frame(height: 200)
                }
                .padding()
                .background(Color(hex: "F9FAFD"))
                .clipShape(.rect(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 20) {
                    Text("Dailoz.YourActivity.Title")
                        .font(.robotoB(22))
                        .foregroundStyle(.textSecondary)

                    Chart(vm.previous12DaysData) { data in
                        BarMark(
                            x: .value("Dailoz.Date.Title", data.date),
                            y: .value("Dailoz.TaskCount.Title", data.count)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(data.type.color)
                    }
                    .padding()
                    .frame(height: 260)
                    .background(Color(hex: "F9FAFD"))
                    .clipShape(.rect(cornerRadius: 16))
                }
            }
            .padding()
            .navigationTitle("Features.Activity.ActivityScreen")
            .navigationBarTitleDisplayMode(.inline)
        }
        .id(uiStateManager.refreshId)
        .onAppear {
            vm.fetchData(lang: preferences.appLang)
        }
        .onChange(of: uiStateManager.refreshId) {
            vm.fetchData(lang: preferences.appLang)
        }
        .safeAreaInset(edge: .bottom) {
            Spacer()
                .frame(height: 80)
        }
    }
}

#Preview {
    NavigationStack {
        ActivityScreen()
            .previewEnvironment()
    }
}
