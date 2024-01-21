//
//  ReceiptItemDetailView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Komponents
import SwiftUI

struct ReceiptItemDetailView: View {

    @State var receiptItem: ReceiptItem

    var body: some View {
        List {
            Section {
                HStack(alignment: .center, spacing: 16.0) {
                    ListRow(image: "ListIcon.Price", title: "Receipt.Item.Price")
                    Spacer()
                    Text(format(receiptItem.price))
                        .foregroundStyle(.secondary)
                }
                if let personWhoOrdered = receiptItem.person {
                    HStack(alignment: .center, spacing: 16.0) {
                        ListRow(image: "ListIcon.Orderer", title: "Receipt.Item.Orderer")
                        Spacer()
                        PersonRow(person: personWhoOrdered)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(alignment: .center, spacing: 16.0) {
                    ListRow(image: "ListIcon.Paid", title: "Receipt.Item.Paid")
                    Spacer()
                    Text(receiptItem.paid ? "Receipt.Item.Paid.Yes" : "Receipt.Item.Paid.No")
                        .foregroundStyle(.secondary)
                }
            } header: {
                ListSectionHeader(text: "Receipt.Item.BasicInformation")
                    .font(.body)
            }
            Section {
                ForEach(receiptItem.receipts ?? []) { receipt in
                    NavigationLink(value: ViewPath.receiptDetail(receipt: receipt)) {
                        ListRow(image: "ListIcon.Receipt", title: receipt.name)
                    }
                }
            } header: {
                ListSectionHeader(text: "Receipt.Item.ReceiptInformation")
                    .font(.body)
            }
        }
        .navigationTitle(receiptItem.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
