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
            Text(price.formatted(.currency(code: Locale.current.currencySymbol!)))
        }
    }
}
