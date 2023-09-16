//
//  ReceiptItemAssignableRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptItemAssignableRow: View {

    @Query private var people: [Person]
    @State var name: String
    @State var price: Double
    @Binding var personWhoOrdered: Person?

    var body: some View {
        HStack(alignment: .top, spacing: 4.0) {
            Text(LocalizedStringKey(name))
            Spacer()
            Text(price, format: .currency(code: "SGD"))
        }
        .font(.system(size: 14.0))
        .monospaced()
    }
}
