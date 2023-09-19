//
//  ReceiptItemsWidget.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

struct ReceiptItemsWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "com.tsubuzaki.Meloan.ReceiptItemsWidget",
                               intent: ReceiptIntent.self,
                               provider: Provider()) { entry in
            ReceiptItemsWidgetView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Widget.ReceiptItems.Title")
        .description("Widget.ReceiptItems.Description")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ReceiptItemsWidgetView: View {

    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let receipt = entry.receipt {
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
                VStack(alignment: .leading, spacing: 8.0) {
                    ForEach(receipt.receiptItems.sorted(by: { $0.dateAdded < $1.dateAdded })) { item in
                        Button(intent: TogglePaidIntent(id: item.id)) {
                            ReceiptItemWidgetRow(photoData: item.person?.photo,
                                                 name: item.name,
                                                 price: item.price)
                                .strikethrough(item.paid)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
                Divider()
                HStack(alignment: .center, spacing: 8.0) {
                    Text("Widget.Total.Large")
                    Spacer()
                    Text("\(receipt.sum(), specifier: "%.2f")")
                }
                .font(.system(size: 14.0))
                .monospaced()
            } else {
                Spacer()
            }
        }
    }
}

struct ReceiptItemWidgetRow: View {

    var photoData: Data?
    var name: String
    var price: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack(alignment: .center, spacing: 8.0) {
                Group {
                    if let photoData = photoData, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        Image("Profile.Shared.Circle")
                            .resizable()
                    }
                }
                .frame(width: 16.0, height: 16.0)
                .clipShape(Circle())
                Text(name)
                Spacer()
                Text("\(price, specifier: "%.2f")")
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 14.0))
            .monospaced()
            .frame(maxWidth: .infinity)
            Divider()
        }
    }
}
