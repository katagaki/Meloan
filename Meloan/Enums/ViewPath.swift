//
//  ViewPath.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation

enum ViewPath: Hashable {
    case moreAttributions
    case receiptDetail(receipt: Receipt)
    case personEditor(person: Person)
    case receiptAssignor
}
