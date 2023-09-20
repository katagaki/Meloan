//
//  ReceiptIOUWidget.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/20.
//

import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

struct ReceiptIOUWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "com.tsubuzaki.Meloan.ReceiptIOUWidget",
                               intent: ReceiptIntent.self,
                               provider: Provider()) { entry in
            ReceiptIOUWidgetView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Widget.ReceiptIOU.Title")
        .description("Widget.ReceiptIOU.Description")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ReceiptIOUWidgetView: View {

    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let receipt = entry.receipt {
                HStack(alignment: .center, spacing: 8.0) {
                    Text(receipt.name)
                        .font(.system(size: 17.0))
                        .bold()
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Text(receipt.isPaid() ? LocalizedStringKey("Widget.Paid.Yes") :
                            LocalizedStringKey("Widget.Paid.No"))
                    .textCase(.uppercase)
                    .foregroundStyle(.white)
                    .font(.system(size: 15.0))
                    .bold()
                    .padding([.leading, .trailing], 4.0)
                    .padding([.top, .bottom], 2.0)
                    .background(receipt.isPaid() ? Color.green : Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                Divider()
                if let personWhoPaid = receipt.personWhoPaid {
                    VStack(alignment: .leading, spacing: 8.0) {
                        HStack(alignment: .center, spacing: 8.0) {
                            ForEach(receipt.participants().prefix(4)) { person in
                                    ReceiptIOUPersonView(photoData: person.photo,
                                                         name: person.name,
                                                         amount: receipt.sumOwed(to: personWhoPaid, for: person))
                                    if person != receipt.participants().prefix(4).last {
                                        Divider()
                                    }
                                }
                        }
                        if family == .systemLarge && receipt.peopleWhoParticipated.count > 4 {
                            Divider()
                            HStack(alignment: .center, spacing: 8.0) {
                                ForEach(receipt.participants()[4..<min(8, receipt.participants().count)]) { person in
                                        ReceiptIOUPersonView(photoData: person.photo,
                                                             name: person.name,
                                                             amount: receipt.sumOwed(to: personWhoPaid, for: person))
                                        if person != receipt.participants().prefix(8).last {
                                            Divider()
                                        }
                                    }
                            }
                        }
                    }
                }
                if family == .systemLarge {
                    Spacer(minLength: 0)
                    Divider()
                    HStack(alignment: .center, spacing: 8.0) {
                        Text("Widget.Total.Large")
                        Spacer()
                        Text("\(receipt.sum(), specifier: "%.2f")")
                    }
                    .font(.system(size: 14.0))
                    .monospaced()
                }
            } else {
                Spacer()
            }
        }
    }
}

struct ReceiptIOUPersonView: View {

    var photoData: Data?
    var name: String
    var amount: Double

    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            VStack(alignment: .center, spacing: 8.0) {
                Group {
                    if let photoData = photoData, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        Image("Profile.Generic.Circle")
                            .resizable()
                    }
                }
                .frame(width: 40.0, height: 40.0)
                .clipShape(Circle())
                Text(name)
                    .font(.system(size: 17.0))
                Text("\(amount, specifier: "%.2f")")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14.0))
                    .monospaced()
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity)
        }
    }
}
