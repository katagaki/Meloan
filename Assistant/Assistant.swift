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

    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let receipt = entry.receipt {
                switch family {
                case .systemSmall:
                    Text(receipt.name)
                        .font(.caption)
                        .bold()
                        .lineLimit(1)
                    Divider()
                    Group {
                        if receipt.isPaid() {
                            Text(LocalizedStringKey("Widget.Paid.Yes"))
                                .foregroundStyle(Color.secondary)
                        } else {
                            Text(NSLocalizedString("Widget.Total.Unpaid", comment: "")
                                .replacingOccurrences(of: "%1", with: String(format: "%.2f", receipt.sumUnpaid())))
                            .foregroundStyle(.red)
                            .bold()
                        }
                        Text(NSLocalizedString("Widget.Total", comment: "")
                            .replacingOccurrences(of: "%1", with: String(format: "%.2f", receipt.sum())))
                    }
                    .font(.subheadline)
                    Spacer()
                default:
                    HStack(alignment: .center, spacing: 8.0) {
                        Text(receipt.name)
                            .bold()
                        Spacer()
                        Text(receipt.isPaid() ? LocalizedStringKey("Widget.Paid.Yes") :
                                LocalizedStringKey("Widget.Paid.No"))
                        .foregroundStyle(.primary)
                        .font(.subheadline)
                        .bold()
                        .padding([.leading, .trailing], 4.0)
                        .padding([.top, .bottom], 2.0)
                        .background(receipt.isPaid() ? Color.green : Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    Divider()
                    VStack(alignment: .center, spacing: 4.0) {
                        HStack(alignment: .center, spacing: 8.0) {
                            Text("Widget.Total.Paid.Large")
                            Spacer()
                            Text("Widget.Total.Unpaid.Large")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        HStack(alignment: .center, spacing: 8.0) {
                            Text("\(receipt.sumPaid(), specifier: "%.2f")")
                            .font(.subheadline)
                            ProgressView(value: receipt.sumPaid(), total: receipt.sum())
                                .progressViewStyle(.linear)
                                .tint(.accent)
                            Text("\(receipt.sumUnpaid(), specifier: "%.2f")")
                            .font(.subheadline)
                        }
                        .bold()
                        Text(NSLocalizedString("Widget.Total", comment: "")
                            .replacingOccurrences(of: "%1", with: String(format: "%.2f", receipt.sum())))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                Spacer()
            }
            Divider()
            HStack(alignment: .center, spacing: 8.0) {
                Image(systemName: "clock")
                switch family {
                case .systemSmall: Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                default: Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                }
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
