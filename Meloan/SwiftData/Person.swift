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
    var name: String
    var photo: Data?
    var id: String

    init(name: String) {
        self.name = name
        self.photo = nil
        self.id = UUID().uuidString
    }

    init(name: String, photo: Data?) {
        self.name = name
        self.photo = photo
        self.id = UUID().uuidString
    }
}
