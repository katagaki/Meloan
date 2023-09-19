//
//  Assistant.swift
//  Assistant
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import WidgetKit
import SwiftData
import SwiftUI

struct Provider: TimelineProvider {

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

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
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
        let entry = SimpleEntry(date: Date(), receipt: receipt)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Get receipt
        // TODO: Allow configuration to select which receipt to show
        var receipt: Receipt?
        let descriptor = FetchDescriptor<Receipt>()
        if let receipts = try? sharedModelContainer.mainContext.fetch(descriptor) {
            receipts.forEach { receipt in
                debugPrint("\(receipt.id): \(receipt.name)")
            }
            receipt = receipts.first
        }
        // Create entry to pass to widget
        var entries: [SimpleEntry] = []
        let entry = SimpleEntry(date: Date(), receipt: receipt)
        entries.append(entry)
        // Return timeline with entry
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = Date()
    var receipt: Receipt?
}

struct AssistantEntryView: View {

    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let receipt = entry.receipt {
                Text(receipt.name)
                    .bold()
                Text(NSLocalizedString("Widget.Total", comment: "")
                    .replacingOccurrences(of: "%1", with: String(format: "%.2f", receipt.sum())))
                .font(.subheadline)
                Text(receipt.isPaid() ? LocalizedStringKey("Widget.Paid.Yes") : LocalizedStringKey("Widget.Paid.No"))
                    .foregroundStyle(receipt.isPaid() ? Color.secondary : Color.orange)
                    .font(.subheadline)
            }
            Spacer()
            Divider()
            HStack(alignment: .center, spacing: 8.0) {
                Image(systemName: "clock")
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
            }
            .foregroundStyle(.tertiary)
            .font(.caption)
        }
    }
}

struct Assistant: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Receipt", provider: Provider()) { entry in
            AssistantEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget.Receipt.Title")
        .description("Widget.Receipt.Description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
