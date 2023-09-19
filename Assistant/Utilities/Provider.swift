//
//  Provider.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import Foundation
import SwiftData
import WidgetKit

struct Provider: AppIntentTimelineProvider {

    typealias Entry = ReceiptEntry
    typealias Intent = ReceiptIntent

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

    func placeholder(in context: Context) -> ReceiptEntry {
        ReceiptEntry(date: Date())
    }

    @MainActor
    func snapshot(for configuration: ReceiptIntent, in context: Context) async -> ReceiptEntry {
        // Get first receipt for snapshot
        var receipt: Receipt?
        let descriptor = FetchDescriptor<Receipt>()
        if let receipts = try? sharedModelContainer.mainContext.fetch(descriptor) {
            receipts.forEach { receipt in
                debugPrint("\(receipt.id): \(receipt.name)")
            }
            receipt = receipts.first
        }
        // Create entry to pass to widget
        let entry = ReceiptEntry(date: Date(), receipt: receipt)
        return entry
    }

    @MainActor
    func timeline(for configuration: ReceiptIntent, in context: Context) async -> Timeline<ReceiptEntry> {
        // Get receipt
        // TODO: Allow configuration to select which receipt to show
        var receipt: Receipt?
        let selectedReceiptID = configuration.receipt.id
        let descriptor = FetchDescriptor<Receipt>(
            predicate: #Predicate<Receipt> { $0.id == selectedReceiptID },
            sortBy: [SortDescriptor(\Receipt.name)])
        if let receipts = try? sharedModelContainer.mainContext.fetch(descriptor) {
            receipt = receipts.first
        }
        // Return timeline with entry to pass to widget
        let timeline = Timeline(entries: [ReceiptEntry(date: Date(), receipt: receipt)], policy: .atEnd)
        return timeline
    }
}
