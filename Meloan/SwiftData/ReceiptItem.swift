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
    var paid: Bool = false
    @Relationship(deleteRule: .noAction) var person: Person?
    var dateAdded: Date = Date()

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

    func setPurchaser(to person: Person?) {
        self.person = person
    }
}
