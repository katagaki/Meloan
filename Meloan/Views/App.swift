//
//  App.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import SwiftUI
import SwiftData

@main
struct MeloanApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Receipt.self, Person.self, ReceiptItem.self, DiscountItem.self, TaxItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject var tabManager = TabManager()
    @StateObject var navigationManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(tabManager)
                .environmentObject(navigationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
