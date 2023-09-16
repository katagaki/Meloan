//
//  ReceiptItemCompactRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemCompactRow: View {

    var name: String
    var price: Double

    var body: some View {
        HStack(alignment: .top, spacing: 4.0) {
            Text(LocalizedStringKey(name))
            Spacer()
            Text(price, format: .currency(code: "SGD"))
            // TODO: Allow selection of currency per receipt
//            if let currencyCode = Locale.current.currency?.identifier {
//                Text(price.formatted(.currency(code: currencyCode)))
//            } else {
//                Text("\(price, specifier: "%.2f")")
//            }
        }
        .font(.system(size: 14.0))
        .monospaced()
    }
}
