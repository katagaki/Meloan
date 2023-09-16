//
//  Receipt.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation
import SwiftData

@Model
final class Receipt {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    @Relationship(deleteRule: .cascade) var receiptItems: [ReceiptItem] = []
    @Relationship(deleteRule: .cascade) var discountItems: [DiscountItem] = []
    @Relationship(deleteRule: .cascade) var taxItems: [TaxItem] = []
    @Relationship(deleteRule: .noAction) var personWhoPaid: Person

    init(name: String,
         paidBy person: Person) {
        self.name = name
        self.personWhoPaid = person
    }

    func addReceiptItems(from receiptItems: [ReceiptItem]) {
        self.receiptItems.append(contentsOf: receiptItems)
    }

    func addDiscountItems(from discountItems: [DiscountItem]) {
        self.discountItems.append(contentsOf: discountItems)
    }
    func addTaxItems(from taxItems: [TaxItem]) {
        self.taxItems.append(contentsOf: taxItems)
    }
}
