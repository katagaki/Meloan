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
    var id: String = UUID().uuidString
    var name: String = ""
    var price: Double = 0.0
    var amount: Int = 0
    var paid: Bool = false
    @Relationship(deleteRule: .noAction) var person: Person?
    @Relationship(inverse: \Receipt.receiptItems) var receipts: [Receipt] = []
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
