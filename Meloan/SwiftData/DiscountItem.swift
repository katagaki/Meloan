//
//  DiscountItem.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation
import SwiftData

@Model
final class DiscountItem {
    var name: String
    var price: Double
    var dateAdded: Date = Date()

    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }

    init(from editable: ReceiptItemEditable) {
        self.name = editable.name
        self.price = editable.price
    }
}
