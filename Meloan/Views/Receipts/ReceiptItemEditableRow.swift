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
        GeometryReader { metrics in
            HStack(alignment: .center) {
                TextField(LocalizedStringKey(placeholderText), text: $name)
                    .frame(minWidth: metrics.size.width * 0.65)
                Divider()
                TextField("Receipt.Price", value: $price,
                          format: .number.precision(.fractionLength(2)).grouping(.never))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            .font(.system(size: 14.0))
            .monospaced()
        }
    }
}
