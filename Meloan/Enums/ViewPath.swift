//
//  ViewPath.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Foundation

enum ViewPath: Hashable {
    case receiptDetail(receipt: Receipt)
    case receiptEditor(receipt: Receipt)
    case receiptItemDetail(receiptItem: ReceiptItem)
    case personCreator
    case personDetail(person: Person)
    case personEditor(person: Person)
    case receiptAssignor
    case moreAttributions
}
