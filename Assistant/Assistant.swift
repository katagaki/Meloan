//
//  Assistant.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import SwiftData
import SwiftUI
import WidgetKit

struct Assistant: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.tsubuzaki.Meloan.ReceiptWidget", provider: Provider()) { entry in
            ReceiptWidget(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget.Receipt.Title")
        .description("Widget.Receipt.Description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
