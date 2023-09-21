//
//  TaxItem.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation
import SwiftData

@Model
final class TaxItem {
    var name: String = ""
    var price: Double = 0.0
    @Relationship(inverse: \Receipt.taxItems) var receipts: [Receipt]? = []
    var dateAdded: Date = Date.now

    init(name: String, price: Double) {
        self.name = name
        self.price = price
    }
}
