//
//  ReceiptIntent.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import AppIntents
import Foundation
import SwiftData
import WidgetKit

struct ReceiptIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Widget.Receipt.Config.Title"
    static var description = IntentDescription("Widget.Receipt.Config.Text")

    @Parameter(title: "Widget.Receipt.Config.Label") var receipt: ReceiptEntity

    init(receipt: ReceiptEntity) {
        self.receipt = receipt
    }

    init() { }

}
