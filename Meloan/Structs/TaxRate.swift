//
//  TaxRate.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/23.
//

import Foundation

struct TaxRate: Codable, Hashable {
    var type: TRType
    var currency: String?
    var rate: Double
    var states: [String: TaxRate]?

    typealias List = [String: TaxRate]

    enum TRType: String, Codable {
        case none = "none"
        case goodsServicesTax = "gst"
        case valueAddedTax = "vat"
    }
}
