//
//  ReceiptItemEditable.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation
import SwiftUI

struct ReceiptItemEditable: Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var price: Double = 0.0
    var amount: Int = 1
    var person: Person?
}
