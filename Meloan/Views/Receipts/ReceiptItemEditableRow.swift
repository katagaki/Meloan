//
//  ReceiptItemEditableRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemEditableRow: View {

    @EnvironmentObject var settings: SettingsManager
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
        GeometryReader { metrics in
            HStack(alignment: .center, spacing: 16.0) {
                TextField(LocalizedStringKey(placeholderText), text: $name)
                    .textInputAutocapitalization(.words)
                    .frame(minWidth: metrics.size.width * 0.65)
                Divider()
                TextField("Receipt.Price", value: $price, formatter: settings.formatter())
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .monospaced()
                    .font(.system(size: 14.0))
            }
        }
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
}
