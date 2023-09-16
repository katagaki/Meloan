//
//  ReceiptItem.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation
import SwiftData

@Model
final class ReceiptItem {
    var name: String
    var price: Double
    var amount: Int
    @Relationship(deleteRule: .cascade) var person: Person?

    init(name: String, price: Double, amount: Int, purchasedBy person: Person) {
        self.name = name
        self.price = price
        self.amount = amount
        self.person = person
    }

    init(name: String, price: Double, amount: Int) {
        self.name = name
        self.price = price
        self.amount = amount
    }

    init(from editable: ReceiptItemEditable) {
        self.name = editable.name
        self.price = editable.price
        self.amount = editable.amount
    }
}
