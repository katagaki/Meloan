//
//  ReceiptEditor.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Komponents
import SwiftData
import SwiftUI

struct ReceiptEditor: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State var receipt: Receipt

    var body: some View {
        List {
            Section {
                TextField("Receipt.Name", text: $receipt.name)
            }
            Section {
                NavigationLink {
                    PeoplePicker(title: "Receipt.Participants", selection: $receipt.peopleWhoParticipated)
                } label: {
                    HStack {
                        Text("Receipt.Participants")
                            .bold()
                        Spacer()
                        Text(NSLocalizedString("Receipt.Participants.Label", comment: "")
                            .replacingOccurrences(of: "%1", with: String(receipt.peopleWhoParticipated.count)))
                        .lineLimit(1)
                        .truncationMode(.head)
                        .foregroundStyle(.secondary)
                    }
                }
                Picker(selection: $receipt.personWhoPaid) {
                    Text("Shared.NoSelection")
                        .tag(nil as Person?)
                    ForEach(receipt.peopleWhoParticipated) { person in
                        PersonRow(person: person)
                            .tag(person as Person?)
                    }
                } label: {
                    Text("Receipt.PaidBy")
                        .bold()
                }
                .pickerStyle(.navigationLink)
            } footer: {
                Text("Receipt.Participants.Description")
                    .font(.body)
            }
            Section {
                ForEach($receipt.receiptItems) { $item in
                    ReceiptItemAssignableRow(name: $item.name, price: $item.price,
                                             personWhoOrdered: $item.person,
                                             peopleWhoParticipated: $receipt.peopleWhoParticipated,
                                             placeholderText: "Receipt.ProductName")
                }
                .onDelete { indexSet in
                    receipt.receiptItems.remove(atOffsets: indexSet)
                }
            } header: {
                HStack(alignment: .center, spacing: 4.0) {
                    ListSectionHeader(text: "Receipt.PurchasedItems")
                        .font(.body)
                    Spacer()
                    Button {
                        receipt.addReceiptItems(from: [ReceiptItem(name: "", price: 0.0, amount: 1)])
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            Section {
                ForEach($receipt.discountItems) { $item in
                    ReceiptItemEditableRow(name: $item.name, price: $item.price,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    receipt.discountItems.remove(atOffsets: indexSet)
                }
            } header: {
                HStack(alignment: .center, spacing: 4.0) {
                    ListSectionHeader(text: "Receipt.Discounts")
                        .font(.body)
                    Spacer()
                    Button {
                        receipt.addDiscountItems(from: [DiscountItem(name: "", price: 0.0)])
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            Section {
                ForEach($receipt.taxItems) { $item in
                    ReceiptItemEditableRow(name: $item.name, price: $item.price,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    receipt.taxItems.remove(atOffsets: indexSet)
                }
            } header: {
                HStack(alignment: .center, spacing: 4.0) {
                    ListSectionHeader(text: "Receipt.Tax")
                        .font(.body)
                    Spacer()
                    Button {
                        receipt.addTaxItems(from: [TaxItem(name: "", price: 0.0)])
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .navigationTitle("Receipt.Create.Title")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: receipt.peopleWhoParticipated) { _, _ in
            if let personWhoPaid = receipt.personWhoPaid {
                if !receipt.peopleWhoParticipated.contains(where: { $0.id == personWhoPaid.id }) {
                    receipt.personWhoPaid = nil
                }
            }
        }
    }
}
