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
    @Relationship(deleteRule: .noAction) var personWhoPaid: Person?
    @Relationship(deleteRule: .noAction) var peopleWhoParticipated: [Person] = []

    init(name: String) {
        self.name = name
    }

    func sum() -> Double {
        let sumOfItems = sumOfItems()
        let sumOfTax = sumOfTax()
        let sumOfDiscount = sumOfDiscount()
        return sumOfItems + sumOfTax - sumOfDiscount
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

    func overallRate() -> Double {
        return sum() / sumOfItems()
    }

    func sumOfSharedItemCost() -> Double {
        return receiptItems.reduce(into: 0.0, { partialResult, item in
            if item.person == nil {
                partialResult += item.price
            }
        })
    }

    func sumOfSharedItemCostPerPerson() -> Double {
        return sumOfSharedItemCost() / Double(peopleWhoParticipated.count)
    }

    func sumOfItemCost(for person: Person) -> Double {
        return receiptItems.reduce(into: 0.0, { partialResult, item in
            if let itemPerson = item.person, itemPerson.id == person.id {
                partialResult += item.price
            }
        })
    }

    func sumOwed(to lender: Person, for borrower: Person) -> Double {
        if ((personWhoPaid?.id ?? "") == lender.id) && contains(participant: borrower) {
            debugPrint("Calculating sum owed to \(lender.name) from \(borrower.name) in receipt \(name)")
            debugPrint("Calculation: \(sumOfItemCost(for: borrower)) + \(sumOfSharedItemCostPerPerson()) * \(overallRate())")
            debugPrint("Participants: \(peopleWhoParticipated.reduce(into: "", { partialResult, person in partialResult += " \(person.name)" }))")
            return (sumOfItemCost(for: borrower) + sumOfSharedItemCostPerPerson()) * overallRate()
        }
        return .zero
    }

    func contains(participant person: Person) -> Bool {
        return peopleWhoParticipated.contains(where: { $0.id == person.id })
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
