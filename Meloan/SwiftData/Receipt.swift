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
    var name: String
    var receiptItems: [ReceiptItem]
    var discountItems: [DiscountItem]
    var taxItems: [TaxItem]
    var personWhoPaid: Person

    init(name: String,
         items receiptItems: [ReceiptItem] = [],
         discounts discountItems: [DiscountItem] = [],
         tax taxItems: [TaxItem] = [],
         paidBy person: Person) {
        self.name = name
        self.receiptItems = receiptItems
        self.discountItems = discountItems
        self.taxItems = taxItems
        self.personWhoPaid = person
    }
}
