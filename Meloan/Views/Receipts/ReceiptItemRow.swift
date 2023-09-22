//
//  ReceiptItemRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import SwiftUI

struct ReceiptItemRow: View {

    @EnvironmentObject var settings: SettingsManager
    @State var name: String
    @State var price: Double

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Text(name)
            Spacer()
            Text(settings.format(price))
                .font(.system(size: 14.0))
                .monospaced()
        }
        .tint(.primary)
    }
}
