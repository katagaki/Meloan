//
//  ReceiptDetailView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import Komponents
import SwiftUI

struct ReceiptDetailView: View {

    @State var receipt: Receipt

    var body: some View {
        List {
            Section {
                ForEach(receipt.peopleWhoParticipated.sorted(by: { lhs, _ in
                    lhs.id == receipt.personWhoPaid?.id ?? ""
                })) { person in
                    PersonRow(person: person, isPersonWhoPaid: person.id == receipt.personWhoPaid?.id ?? "")
                }
            } header: {
                ListSectionHeader(text: "Receipt.Participants")
                    .font(.body)
            }
            Section {
                ForEach(receipt.receiptItems) { item in
                    Button {
                        item.paid.toggle()
                    } label: {
                        HStack(alignment: .center, spacing: 16.0) {
                            Group {
                                if let person = item.person {
                                    if let data = person.photo, let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                    } else {
                                        Image("Profile.Generic")
                                            .resizable()
                                    }
                                } else {
                                    Image("Profile.Shared")
                                        .resizable()
                                }
                            }
                            .frame(width: 32.0, height: 32.0)
                            .clipShape(Circle())
                            ReceiptItemRow(name: item.name, price: item.price)
                                .strikethrough(item.paid)
                        }
                    }
                }
            } header: {
                ListSectionHeader(text: "Receipt.PurchasedItems")
                    .font(.body)
            } footer: {
                HStack(alignment: .center, spacing: 4.0) {
                    Text("Receipt.Total")
                    Spacer()
                    Text("\(receipt.sumOfItems(), specifier: "%.2f")")
                }
                .font(.body)
                .bold()
                .foregroundStyle(.primary)
            }
            Section {
                ForEach(receipt.discountItems) { item in
                    ReceiptItemRow(name: item.name, price: item.price)
                }
            } header: {
                ListSectionHeader(text: "Receipt.Discounts")
                    .font(.body)
            }
            Section {
                ForEach(receipt.taxItems) { item in
                    ReceiptItemRow(name: item.name, price: item.price)
                }
            } header: {
                ListSectionHeader(text: "Receipt.Tax")
                    .font(.body)
            } footer: {
                HStack(alignment: .center, spacing: 4.0) {
                    Text("Receipt.Tax.Detail")
                    Spacer()
                    Text("\(Int(receipt.taxRate() * 100), specifier: "%d")%")
                }
                .font(.body)
                .bold()
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle(receipt.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
