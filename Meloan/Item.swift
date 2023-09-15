//
//  Item.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
