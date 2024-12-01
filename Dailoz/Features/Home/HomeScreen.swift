//
//  HomeScreen.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        List {
            ForEach(1..<51) { index in
                Text("Item \(index)")

            }
        }
        .navigationTitle("Home Screen")
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
    }
}
