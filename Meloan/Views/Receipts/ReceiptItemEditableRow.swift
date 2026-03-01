//
//  ReceiptItemEditableRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemEditableRow: View {

    @State var discountItem: DiscountItem?
    @State var taxItem: TaxItem?
    @State var name: String
    @State var price: Double
    var placeholderText: String

    init(discountItem: DiscountItem, placeholderText: String) {
        self.discountItem = discountItem
        self.name = discountItem.name
        self.price = discountItem.price
        self.placeholderText = placeholderText
    }

    init(taxItem: TaxItem, placeholderText: String) {
        self.taxItem = taxItem
        self.name = taxItem.name
        self.price = taxItem.price
        self.placeholderText = placeholderText
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            TextField(LocalizedStringKey(placeholderText), text: $name)
                .textInputAutocapitalization(.words)
            Divider()
            TextField("Receipt.Price", value: $price, formatter: formatter())
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .monospaced()
                .font(.system(size: 14.0))
                .frame(maxWidth: 120.0)
        }
        .disabled(shouldBeDisabled())
        .foregroundStyle(shouldBeDisabled() ? Color.secondary : Color.primary)
        .onChange(of: name, initial: false) { _, _ in
            if let discountItem = discountItem {
                discountItem.name = name
            } else if let taxItem = taxItem {
                taxItem.name = name
            }
        }
        .onChange(of: price, initial: false) { _, _ in
            if let discountItem = discountItem {
                discountItem.price = price
            } else if let taxItem = taxItem {
                taxItem.price = price
            }
        }
    }

    func shouldBeDisabled() -> Bool {
        if let taxItem = taxItem,
           taxItem.id.starts(with: "AUTOTAX-") || taxItem.id.starts(with: "AUTOTEN-") {
            return true
        }
        return false
    }
}
