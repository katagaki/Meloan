//
//  ReceiptItemRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import SwiftUI

struct ReceiptItemRow: View {

    @State var name: String
    @State var price: Double
    @State var priceFontSize: Double = 14.0

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Text(name)
            Spacer()
            Text(format(price))
                .font(.system(size: priceFontSize))
                .monospaced()
        }
        .tint(.primary)
    }
}
