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

    @StateObject var tabManager = TabManager()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var settings = SettingsManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(tabManager)
                .environmentObject(navigationManager)
                .environmentObject(settings)
        }
        .modelContainer(sharedModelContainer)
    }

    static func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "com.tsubuzaki.Meloan.ReceiptWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "com.tsubuzaki.Meloan.ReceiptItemsWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "com.tsubuzaki.Meloan.ReceiptIOUWidget")
    }
}
