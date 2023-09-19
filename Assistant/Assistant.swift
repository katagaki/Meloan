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
        AppIntentConfiguration(kind: "com.tsubuzaki.Meloan.ReceiptWidget",
                               intent: ReceiptIntent.self,
                               provider: Provider()) { entry in
            ReceiptWidget(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Widget.Receipt.Title")
        .description("Widget.Receipt.Description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
