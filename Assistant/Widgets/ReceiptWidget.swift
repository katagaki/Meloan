//
//  ReceiptWidget.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

struct ReceiptWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "com.tsubuzaki.Meloan.ReceiptWidget",
                               intent: ReceiptIntent.self,
                               provider: Provider()) { entry in
            ReceiptWidgetView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Widget.Receipt.Title")
        .description("Widget.Receipt.Description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ReceiptWidgetView: View {

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
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
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
