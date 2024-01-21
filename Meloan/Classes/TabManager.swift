//
//  TabManager.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var selectedTab: TabType = .receipts
    @Published var previouslySelectedTab: TabType = .receipts
}
