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
        if let receipt = configuration.receipt {
            // Get receipt for snapshot
            let selectedReceiptID = receipt.id
            var receipt: Receipt?
            let descriptor = FetchDescriptor<Receipt>(
                predicate: #Predicate<Receipt> { $0.id == selectedReceiptID },
                sortBy: [SortDescriptor(\Receipt.name)])
            do {
                let receipts = try sharedModelContainer.mainContext.fetch(descriptor)
                receipt = receipts.first
                // Create entry to pass to widget
                let entry = ReceiptEntry(date: Date(), receipt: receipt)
                return entry
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return ReceiptEntry(date: Date())
    }

    @MainActor
    func timeline(for configuration: ReceiptIntent, in context: Context) async -> Timeline<ReceiptEntry> {
        if let receipt = configuration.receipt {
            // Get receipt for timeline
            let selectedReceiptID = receipt.id
            var receipt: Receipt?
            let descriptor = FetchDescriptor<Receipt>(
                predicate: #Predicate<Receipt> { $0.id == selectedReceiptID },
                sortBy: [SortDescriptor(\Receipt.name)])
            do {
                let receipts = try sharedModelContainer.mainContext.fetch(descriptor)
                receipt = receipts.first
                // Return timeline with entry to pass to widget
                let timeline = Timeline(entries: [ReceiptEntry(date: Date(), receipt: receipt)], policy: .atEnd)
                return timeline
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return Timeline(entries: [], policy: .atEnd)
    }
}
