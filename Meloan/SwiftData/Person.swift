//
//  Item.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import Foundation
import SwiftData

@Model
final class Person {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var photo: Data?
    @Relationship(inverse: \Receipt.personWhoPaid) var receiptsPaid: [Receipt]?
    @Relationship(inverse: \Receipt.peopleWhoParticipated) var receiptsParticipated: [Receipt]?
    var dateAdded: Date = Date()

    init(name: String) {
        self.name = name
        self.photo = nil
    }

    init(name: String, photo: Data?) {
        self.name = name
        self.photo = photo
    }

    func sumOwed(to personWhoPaid: Person?) -> Double {
        if let personWhoPaid = personWhoPaid {
            var sum: Double = .zero
            for receipt in receiptsParticipated ?? [] where receipt.personWhoPaid == personWhoPaid {
                sum += receipt.sumOwed(to: personWhoPaid, for: self)
            }
            return sum
        }
        return .zero
    }
}
