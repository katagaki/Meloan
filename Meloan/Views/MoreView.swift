//
//  MoreView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftUI

struct MoreView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.moreTabPath) {
            MoreList(repoName: "katagaki/Meloan", viewPath: ViewPath.moreAttributions) {
                // TODO: Add setting options for default tax rate, currency, etc
                Section {
                    Button {
                        try? modelContext.delete(model: Person.self)
                        try? modelContext.delete(model: ReceiptItem.self)
                        try? modelContext.delete(model: DiscountItem.self)
                        try? modelContext.delete(model: TaxItem.self)
                        try? modelContext.delete(model: Receipt.self)
                    } label: {
                        Text("More.DeleteAllData")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .moreAttributions:
                    LicensesView(licenses: [])
                default: Color.clear
                }
            }
        }
    }
}
