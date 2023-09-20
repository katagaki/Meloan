//
//  App.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import SwiftUI
import SwiftData
import WidgetKit

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

    static func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "com.tsubuzaki.Meloan.ReceiptWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "com.tsubuzaki.Meloan.ReceiptItemsWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "com.tsubuzaki.Meloan.ReceiptIOUWidget")
    }
}
