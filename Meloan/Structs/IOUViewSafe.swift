//
//  IOUViewSafe.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import Foundation

struct IOUViewSafe {
    var personName: String
    var receipts: [String: Double]

    func sum() -> Double {
        return receipts.values.reduce(into: 0.0) { partialResult, value in
            partialResult += value
        }
    }
}
