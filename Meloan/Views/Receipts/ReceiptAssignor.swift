//
//  ReceiptAssignor.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptAssignor: View {

    @Query private var people: [Person]

    @Binding var name: String
    @Binding var receiptItems: [ReceiptItem]
    @Binding var discountItems: [DiscountItem]
    @Binding var taxItems: [TaxItem]
    @Binding var personWhoPaid: Person?

    @State var receiptItemsEditable: [ReceiptItemEditable]
    @State var discountItemsEditable: [ReceiptItemEditable]
    @State var taxItemsEditable: [ReceiptItemEditable]
    @State var onCreate: () -> Void

    var body: some View {
        List {
            ForEach($receiptItemsEditable) { $itemEditable in
                ReceiptItemAssignableRow(name: itemEditable.name, price: itemEditable.price,
                                         personWhoOrdered: $itemEditable.person)
            }
        }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        for receiptItemEditable in receiptItemsEditable {
                            let receiptItem = ReceiptItem(from: receiptItemEditable)
                            receiptItems.append(receiptItem)
                        }
                        onCreate()
                    } label: {
                        Text("Shared.Create")
                    }
                }
            }
            .navigationTitle("Receipt.Assign.Title")
            .navigationBarTitleDisplayMode(.inline)
    }
}
