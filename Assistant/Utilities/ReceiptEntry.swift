//
//  ReceiptEntry.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import Foundation
import WidgetKit

struct ReceiptEntry: TimelineEntry {
    var date: Date = Date()
    var receipt: Receipt?
}
