//
//  MainTabView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import CoreData
import Komponents
import SwiftData
import SwiftUI
import TipKit

struct MainTabView: View {

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var navigationManager: NavigationManager
    @Query var people: [Person]

    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            ReceiptsView()
                .tabItem {
                    Label("TabTitle.Receipts", image: "Tab.Receipts")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .tag(TabType.receipts)
            IOUView()
                .tabItem {
                    Label("TabTitle.IOU", image: "Tab.IOU")
                }
                .toolbarBackground(.hidden, for: .tabBar)
                .tag(TabType.iou)
            PeopleView()
                .tabItem {
                    Label("TabTitle.People", image: "Tab.People")
                }
                .tag(TabType.people)
            SearchView()
                .tabItem {
                    Label("TabTitle.Search", systemImage: "magnifyingglass")
                }
                .tag(TabType.search)
            MoreView()
                .tabItem {
                    Label("TabTitle.More", systemImage: "ellipsis")
                }
                .tag(TabType.more)
        }
        .task {
            createMePerson()
            MeloanApp.reloadWidget()
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
        .onReceive(tabManager.$selectedTab, perform: { newValue in
            if newValue == tabManager.previouslySelectedTab {
                navigationManager.popToRoot(for: newValue)
            }
            tabManager.previouslySelectedTab = newValue
        })
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                tryToReloadData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: NSPersistentCloudKitContainer.eventChangedNotification
        )) { notification in
            // swiftlint:disable line_length
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                return
            }
            // swiftlint:enable line_length
            if event.endDate != nil && event.type == .import {
                tryToReloadData()
            }
        }
    }

    func createMePerson() {
        if !people.contains(where: { $0.id == "ME" }) {
            let mePerson = Person(name: NSLocalizedString("People.Me", comment: ""))
            mePerson.id = "ME"
            mePerson.photo = UIImage(named: "Profile.Me.Circle")!.pngData()
            modelContext.insert(mePerson)
        } else {
            if let mePerson = people.first(where: { $0.id == "ME" }) {
                mePerson.name = NSLocalizedString("People.Me", comment: "")
            }
        }
    }

    func tryToReloadData() {
        Task { @MainActor in
            _ = try? modelContext.fetch(FetchDescriptor<Receipt>())
        }
    }
}
