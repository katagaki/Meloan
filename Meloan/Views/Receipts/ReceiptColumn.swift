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

    @Query private var receipts: [Receipt]
    @State var receipt: Receipt

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
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
                            ReceiptItemView(name: item.name, price: item.price)
                        }
                        if !receipt.taxItems.isEmpty {
                            Divider()
                            ForEach(receipt.taxItems.sorted(by: { lhs, rhs in
                                lhs.name < rhs.name
                            })) { item in
                                ReceiptItemView(name: item.name, price: item.price)
                            }
                        }
                        if !receipt.discountItems.isEmpty {
                            Divider()
                            ForEach(receipt.discountItems.sorted(by: { lhs, rhs in
                                lhs.name < rhs.name
                            })) { item in
                                ReceiptItemView(name: item.name, price: item.price)
                            }
                        }
                        Divider()
                        ReceiptItemView(name: "Receipt.Total", price: total())
                    }
                    .font(.system(size: 14.0))
                    .monospaced()
                    .padding([.leading, .trailing])
                }
                .padding([.top, .bottom])
            }
            Divider()
            VStack(alignment: .center, spacing: 16.0) {
                ActionButton(text: "Receipt.ShowDetails", icon: "list.triangle", isPrimary: true) {
                    // navigationManager.push(<#T##ViewPath#>, for: <#T##TabType#>)
                }
                ActionButton(text: "Receipt.Edit", icon: "pencil", isPrimary: false) {
                    // navigationManager.push(<#T##ViewPath#>, for: <#T##TabType#>)
                }
            }
            .padding()
        }
        .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
        .frame(width: 288.0)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }

    func total() -> Double {
        let sumOfItems = receipt.receiptItems.reduce(into: 0.0, { partialResult, item in
            partialResult += item.price
        })
        let sumOfTax = receipt.taxItems.reduce(into: 0.0, { partialResult, item in
            partialResult += item.price
        })
        let sumOfDiscount = receipt.discountItems.reduce(into: 0.0, { partialResult, item in
            partialResult += item.price
        })
        return sumOfItems + sumOfTax - sumOfDiscount
    }
}
