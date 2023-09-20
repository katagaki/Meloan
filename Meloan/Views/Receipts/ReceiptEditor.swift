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

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State var receipt: Receipt

    var body: some View {
        List {
            Section {
                TextField("Receipt.Name", text: $receipt.name)
                    .textInputAutocapitalization(.words)
            } header: {
                HStack(alignment: .center, spacing: 8.0) {
                    Image(systemName: "info.circle.fill")
                        .font(.subheadline)
                    Text("Shared.AutoSaving")
                        .font(.subheadline)
                }
                .textCase(.none)
                .padding(.bottom, 16.0)
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
                    ForEach(receipt.peopleWhoParticipated
                        .sorted(by: { $0.id == "ME" || $0.name < $1.name })) { person in
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
                    .font(.subheadline)
            }
            Section {
                ForEach($receipt.receiptItems
                    .sorted(by: { $0.dateAdded.wrappedValue < $1.dateAdded.wrappedValue })) { $item in
                    ReceiptItemAssignableRow(name: $item.name, price: $item.price,
                                             personWhoOrdered: $item.person,
                                             peopleWhoParticipated: $receipt.peopleWhoParticipated,
                                             placeholderText: "Receipt.ProductName")
                }
                .onDelete { indexSet in
                    // Workaround due to unsorted relationship in SwiftData
                    indexSet.forEach { index in
                        let itemsSorted = receipt.receiptItems.sorted(by: { $0.dateAdded < $1.dateAdded })
                        var itemsToDelete: [ReceiptItem] = []
                        indexSet.forEach { index in
                            itemsToDelete.append(itemsSorted[index])
                        }
                        itemsToDelete.forEach { itemToDelete in
                            receipt.receiptItems.removeAll { item in
                                item == itemToDelete
                            }
                        }
                        for item in itemsToDelete {
                            modelContext.delete(item)
                        }
                    }
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
                ForEach($receipt.discountItems
                    .sorted(by: { $0.dateAdded.wrappedValue < $1.dateAdded.wrappedValue })) { $item in
                    ReceiptItemEditableRow(name: $item.name, price: $item.price,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    // Workaround due to unsorted relationship in SwiftData
                    indexSet.forEach { index in
                        let itemsSorted = receipt.discountItems.sorted(by: { $0.dateAdded < $1.dateAdded })
                        var itemsToDelete: [DiscountItem] = []
                        indexSet.forEach { index in
                            itemsToDelete.append(itemsSorted[index])
                        }
                        itemsToDelete.forEach { itemToDelete in
                            receipt.discountItems.removeAll { item in
                                item == itemToDelete
                            }
                        }
                        for item in itemsToDelete {
                            modelContext.delete(item)
                        }
                    }
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
                ForEach($receipt.taxItems
                    .sorted(by: { $0.dateAdded.wrappedValue < $1.dateAdded.wrappedValue })) { $item in
                    ReceiptItemEditableRow(name: $item.name, price: $item.price,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    // Workaround due to unsorted relationship in SwiftData
                    indexSet.forEach { index in
                        let itemsSorted = receipt.taxItems.sorted(by: { $0.dateAdded < $1.dateAdded })
                        var itemsToDelete: [TaxItem] = []
                        indexSet.forEach { index in
                            itemsToDelete.append(itemsSorted[index])
                        }
                        itemsToDelete.forEach { itemToDelete in
                            receipt.taxItems.removeAll { item in
                                item == itemToDelete
                            }
                        }
                        for item in itemsToDelete {
                            modelContext.delete(item)
                        }
                    }
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
        .navigationTitle("Receipt.Edit.Title")
        .navigationBarTitleDisplayMode(.inline)
        // TODO: Implement manual saving
        .onChange(of: receipt.peopleWhoParticipated) { _, _ in
            if let personWhoPaid = receipt.personWhoPaid {
                if !receipt.peopleWhoParticipated.contains(where: { $0.id == personWhoPaid.id }) {
                    receipt.personWhoPaid = nil
                }
            }
        }
        .onChange(of: receipt.name) { _, _ in
            MeloanApp.reloadWidget()
        }
        .onChange(of: receipt.receiptItems) { _, _ in
            MeloanApp.reloadWidget()
        }
        .onChange(of: receipt.discountItems) { _, _ in
            MeloanApp.reloadWidget()
        }
        .onChange(of: receipt.taxItems) { _, _ in
            MeloanApp.reloadWidget()
        }
    }
}
