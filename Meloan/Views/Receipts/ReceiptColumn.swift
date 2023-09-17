//
//  ReceiptColumn.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftData
import SwiftUI

struct ReceiptColumn: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @State var receipt: Receipt

    var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            Text(receipt.name)
                .bold()
                .padding()
            Divider()
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 8.0) {
                    Group {
                        ForEach(receipt.receiptItems.sorted(by: { lhs, rhs in
                            lhs.name < rhs.name
                        })) { item in
                            ReceiptItemCompactRow(name: item.name, price: item.price,
                                                  isPaid: item.paid, person: item.person)
                        }
                        if !receipt.taxItems.isEmpty {
                            Divider()
                            ForEach(receipt.taxItems.sorted(by: { lhs, rhs in
                                lhs.name < rhs.name
                            })) { item in
                                ReceiptItemCompactRow(name: item.name, price: item.price)
                            }
                        }
                        if !receipt.discountItems.isEmpty {
                            Divider()
                            ForEach(receipt.discountItems.sorted(by: { lhs, rhs in
                                lhs.name < rhs.name
                            })) { item in
                                ReceiptItemCompactRow(name: item.name, price: item.price)
                            }
                        }
                        Divider()
                        ReceiptItemCompactRow(name: "Receipt.Total", price: receipt.sum(), hidesPhoto: true)
                    }
                    .padding([.leading, .trailing])
                }
                .padding([.top, .bottom])
            }
            Divider()
            VStack(alignment: .center, spacing: 16.0) {
                ActionButton(text: "Receipt.ShowDetails", icon: "Receipt.ShowDetails", isPrimary: true) {
                    navigationManager.push(ViewPath.receiptDetail(receipt: receipt), for: .receipts)
                }
                ActionButton(text: "Receipt.Edit", icon: "Receipt.Edit", isPrimary: false) {
                    // TODO: Edit receipt
                }
                .disabled(true)
            }
            .padding()
        }
        .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
        .frame(width: 288.0)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}
