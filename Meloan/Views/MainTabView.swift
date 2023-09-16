//
//  MainTabView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            ReceiptsView()
                .tabItem {
                    Label("TabTitle.Receipts", image: "Tab.Receipts")
                }
                .tag(TabType.receipts)
            Color.clear
                .tabItem {
                    Label("TabTitle.IOU", image: "Tab.IOU")
                }
                .tag(TabType.iou)
            PeopleView()
                .tabItem {
                    Label("TabTitle.People", image: "Tab.People")
                }
                .tag(TabType.people)
            MoreView()
                .tabItem {
                    Label("TabTitle.More", systemImage: "ellipsis")
                }
                .tag(TabType.more)
        }
        .onReceive(tabManager.$selectedTab, perform: { newValue in
            if newValue == tabManager.previouslySelectedTab {
                navigationManager.popToRoot(for: newValue)
            }
            tabManager.previouslySelectedTab = newValue
        })
    }
}
