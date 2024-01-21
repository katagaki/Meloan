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
    @Relationship(deleteRule: .nullify) var person: Person?
    @Relationship(deleteRule: .nullify) var peopleWhoPaid: [Person]? = []
    @Relationship(inverse: \Receipt.receiptItems) var receipts: [Receipt]? = []
    var dateAdded: Date = Date.now

    init(name: String, price: Double, amount: Int) {
        self.name = name
        self.price = price
        self.amount = amount
    }

    func setPurchaser(to person: Person?) {
        self.person = person
    }

    func personHasPaid(_ person: Person) -> Bool {
        return peopleWhoPaid?.contains(person) ?? false
    }
    func addPersonWhoPaid(from people: [Person]) {
        peopleWhoPaid?.append(contentsOf: people)
    }

    func removePersonWhoPaid(withID id: String) {
        peopleWhoPaid?.removeAll(where: { $0.id == id })
    }
}
