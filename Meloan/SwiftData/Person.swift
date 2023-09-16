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

    init(name: String) {
        self.name = name
        self.photo = nil
    }

    init(name: String, photo: Data?) {
        self.name = name
        self.photo = photo
    }
}
