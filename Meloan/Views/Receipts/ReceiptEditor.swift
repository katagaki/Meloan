//
//  ReceiptEditor.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Combine
import Komponents
import SwiftData
import SwiftUI

struct ReceiptEditor: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsManager
    @State var widgetReloadDebouncer = PassthroughSubject<String, Never>()
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
                            .replacingOccurrences(of: "%1", with: String(receipt.participants().count)))
                        .lineLimit(1)
                        .truncationMode(.head)
                        .foregroundStyle(.secondary)
                    }
                }
                Picker(selection: $receipt.personWhoPaid) {
                    Text("Shared.NoSelection")
                        .tag(nil as Person?)
                    ForEach(receipt.participants()) { person in
                        PersonRow(person: person)
                            .tag(person as Person?)
                    }
                } label: {
                    Text("Receipt.Payer")
                        .bold()
                }
                .pickerStyle(.navigationLink)
            } footer: {
                Text("Receipt.Participants.Description")
                    .font(.subheadline)
            }
            Section {
                ForEach(receipt.items()) { item in
                    ReceiptItemAssignableRow(item: item,
                                             peopleWhoParticipated: .constant(receipt.participants()),
                                             placeholderText: "Receipt.ProductName")
                }
                .onDelete { indexSet in
                    // Workaround due to unsorted relationship in SwiftData
                    indexSet.forEach { index in
                        let itemsSorted = receipt.items()
                        var itemsToDelete: [ReceiptItem] = []
                        indexSet.forEach { index in
                            itemsToDelete.append(itemsSorted[index])
                        }
                        itemsToDelete.forEach { itemToDelete in
                            receipt.receiptItems?.removeAll { item in
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
                ForEach(receipt.discountItems()) { item in
                    ReceiptItemEditableRow(discountItem: item,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    // Workaround due to unsorted relationship in SwiftData
                    indexSet.forEach { index in
                        let itemsSorted = receipt.discountItems()
                        var itemsToDelete: [DiscountItem] = []
                        indexSet.forEach { index in
                            itemsToDelete.append(itemsSorted[index])
                        }
                        itemsToDelete.forEach { itemToDelete in
                            receipt.discountItems?.removeAll { item in
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
                ForEach(receipt.taxItems()) { item in
                    ReceiptItemEditableRow(taxItem: item,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    // Workaround due to unsorted relationship in SwiftData
                    indexSet.forEach { index in
                        let itemsSorted = receipt.taxItems()
                        var itemsToDelete: [TaxItem] = []
                        indexSet.forEach { index in
                            itemsToDelete.append(itemsSorted[index])
                        }
                        itemsToDelete.forEach { itemToDelete in
                            receipt.taxItems?.removeAll { item in
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
        .navigationTitle(receipt.name)
        .navigationBarTitleDisplayMode(.inline)
        // TODO: Implement manual saving
        .onDisappear {
            if settings.markSelfPaid {
                receipt.setLenderItemsPaid()
            }
        }
        .onChange(of: receipt.peopleWhoParticipated) { _, _ in
            if let personWhoPaid = receipt.personWhoPaid {
                if !receipt.participants().contains(where: { $0.id == personWhoPaid.id }) {
                    receipt.personWhoPaid = nil
                }
            }
        }
        .onChange(of: receipt.name) { _, _ in
            widgetReloadDebouncer.send("")
        }
        .onChange(of: receipt.receiptItems) { _, _ in
            widgetReloadDebouncer.send("")
        }
        .onChange(of: receipt.discountItems) { _, _ in
            widgetReloadDebouncer.send("")
        }
        .onChange(of: receipt.taxItems) { _, _ in
            widgetReloadDebouncer.send("")
        }
        .onChange(of: receipt.personWhoPaid) { _, _ in
            widgetReloadDebouncer.send("")
        }
        .onChange(of: receipt.peopleWhoParticipated) { _, _ in
            widgetReloadDebouncer.send("")
        }
        .onReceive(widgetReloadDebouncer.debounce(for: .seconds(3), scheduler: DispatchQueue.main)) { _ in
            MeloanApp.reloadWidget()
        }
    }
}
