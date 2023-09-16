//
//  ReceiptItemView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftUI

struct ReceiptItemView: View {

    var name: String
    var price: Double

    var body: some View {
        HStack(alignment: .top, spacing: 4.0) {
            Text(LocalizedStringKey(name))
            Spacer()
            Text("$ \(price, specifier: "%.2f")")
            // TODO: Allow selection of currency per receipt
//            if let currencyCode = Locale.current.currency?.identifier {
//                Text(price.formatted(.currency(code: currencyCode)))
//            } else {
//                Text("\(price, specifier: "%.2f")")
//            }
        }
    }
}
