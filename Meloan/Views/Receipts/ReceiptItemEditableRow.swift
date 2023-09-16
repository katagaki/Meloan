//
//  ReceiptItemEditableRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemEditableRow: View {

    @Binding var name: String
    @Binding var price: Double
    var placeholderText: String

    var body: some View {
        HStack(alignment: .center) {
            TextField(LocalizedStringKey(placeholderText), text: $name)
            Divider()
            TextField("Receipt.Price", value: $price, format: .number.precision(.fractionLength(2)).grouping(.never))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
        }
        .font(.system(size: 14.0))
        .monospaced()
    }
}
