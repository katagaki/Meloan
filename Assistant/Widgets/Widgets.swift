//
//  Widgets.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import WidgetKit
import SwiftData
import SwiftUI

@main
struct Widgets: WidgetBundle {
    var body: some Widget {
        ReceiptProgressWidget()
        ReceiptItemsWidget()
    }
}
