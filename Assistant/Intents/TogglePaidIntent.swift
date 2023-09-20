//
//  TogglePaidIntent.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import AppIntents
import Foundation
import SwiftData

struct TogglePaidIntent: AppIntent {

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

    static var title: LocalizedStringResource = "Receipt.MarkPaidIntent.Title"
    static var description = IntentDescription("Receipt.MarkPaidIntent.Description")

    @Parameter(title: "Receipt.MarkPaidIntent.ItemID") var id: String

    init() {
        self.id = ""
    }

    init(id: String) {
        // IMPORTANT: Do NOT remove, if not Swift will whine about String not being IntentParameter<String>.
        self.id = id
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        if let receiptItem = getReceiptItem() {
            receiptItem.paid.toggle()
            try? sharedModelContainer.mainContext.save()
        }
        return .result()
    }

    @MainActor
    func getReceiptItem() -> ReceiptItem? {
        if let allItems = try? sharedModelContainer
            .mainContext.fetch(FetchDescriptor<ReceiptItem>()) {
            return allItems.filter({ $0.id == id }).first
        }
        return nil
    }
}
