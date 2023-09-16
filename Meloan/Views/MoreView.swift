//
//  MoreView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftUI

struct MoreView: View {

    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.moreTabPath) {
            MoreList(repoName: "katagaki/Meloan", viewPath: ViewPath.moreAttributions) {
                // TODO: Add setting options for default tax rate, currency, etc
            }
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .moreAttributions:
                    LicensesView(licenses: [])
                }
            }
        }
    }
}
