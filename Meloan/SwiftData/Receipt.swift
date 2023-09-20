//
//  Receipt.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation
import SwiftData

@Model
final class Receipt: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    @Relationship(deleteRule: .cascade) var receiptItems: [ReceiptItem] = []
    @Relationship(deleteRule: .cascade) var discountItems: [DiscountItem] = []
    @Relationship(deleteRule: .cascade) var taxItems: [TaxItem] = []
    @Relationship(deleteRule: .noAction) var personWhoPaid: Person?
    @Relationship(deleteRule: .noAction) var peopleWhoParticipated: [Person] = []
    var dateAdded: Date = Date()

    init(name: String) {
        self.name = name
    }

    func sum() -> Double {
        return sumOfItems() + sumOfTax() - sumOfDiscount()
    }

    func sumUnpaid() -> Double {
        return receiptItems.reduce(into: 0.0, { partialResult, item in
            if !item.paid {
                partialResult += item.price
            }
        }) * overallRate()
    }

    func sumPaid() -> Double {
        return sum() - sumUnpaid()
    }

    func sumOfItems() -> Double {
        return receiptItems.reduce(into: 0.0, { partialResult, item in
            partialResult += item.price
        })
    }

    func sumOfTax() -> Double {
        return taxItems.reduce(into: 0.0, { partialResult, item in
            partialResult += item.price
        })
    }

    func sumOfDiscount() -> Double {
        return discountItems.reduce(into: 0.0, { partialResult, item in
            partialResult += item.price
        })
    }

    func taxRate() -> Double {
        return sumOfTax() / sumOfItems()
    }

    func overallRate() -> Double {
        return sum() / sumOfItems()
    }

    func sumOfSharedItemCost(excludingPaid: Bool = false) -> Double {
        return receiptItems.reduce(into: 0.0, { partialResult, item in
            if item.person == nil, !excludingPaid || !item.paid {
                partialResult += item.price
            }
        })
    }

    func sumOfSharedItemCostPerPerson(excludingPaid: Bool = false) -> Double {
        return sumOfSharedItemCost(excludingPaid: excludingPaid) / Double(peopleWhoParticipated.count)
    }

    func sumOfItemCost(for person: Person) -> Double {
        return receiptItems.reduce(into: 0.0, { partialResult, item in
            if let itemPerson = item.person, itemPerson.id == person.id, !item.paid {
                partialResult += item.price
            }
        })
    }

    func sumOwed(to lender: Person, for borrower: Person) -> Double {
        if ((personWhoPaid?.id ?? "") == lender.id) && contains(participant: borrower) {
            return (sumOfItemCost(for: borrower) +
                    sumOfSharedItemCostPerPerson(excludingPaid: true)) * overallRate()
        }
        return .zero
    }

    func contains(participant person: Person) -> Bool {
        return peopleWhoParticipated.contains(where: { $0.id == person.id })
    }

    func isPaid() -> Bool {
        return !receiptItems.contains(where: { $0.paid == false })
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

    func setPersonWhoPaid(to personWhoPaid: Person?) {
        self.personWhoPaid = personWhoPaid
    }

    func addPeopleWhoParticipated(from peopleWhoParticipated: [Person]) {
        self.peopleWhoParticipated.append(contentsOf: peopleWhoParticipated)
    }
}
