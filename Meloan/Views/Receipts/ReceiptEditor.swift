//
//  ReceiptEditor.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Komponents
import SwiftData
import SwiftUI
import UIKit

struct ReceiptEditor: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @AppStorage(wrappedValue: true, "MarkSelfPaid", store: defaults) var markSelfPaid: Bool
    @AppStorage(wrappedValue: 0.0, "TaxRate", store: defaults) var taxRate: Double
    @AppStorage(wrappedValue: "", "TaxRateCountry", store: defaults) var taxRateCountry: String
    @AppStorage(wrappedValue: "", "TaxRateType", store: defaults) var taxRateType: String
    @AppStorage(wrappedValue: false, "AddTenPercent", store: defaults) var addTenPercent: Bool
    @AppStorage(wrappedValue: false, "TaxAboveServiceCharge", store: defaults) var taxAboveServiceCharge: Bool
    @State var taxRates: TaxRate.List = Bundle.main.decode(TaxRate.List.self, from: "TaxRates.json")!
    @State var isPersonPickerPresented: Bool = false
    @State var isSaveConfirmed: Bool = false
    @State var draft: ReceiptDraft
    var receipt: Receipt
    var isNewReceipt: Bool = false

    init(receipt: Receipt, isNewReceipt: Bool = false) {
        self.receipt = receipt
        self.isNewReceipt = isNewReceipt
        self._draft = State(initialValue: ReceiptDraft(from: receipt))
    }

    var body: some View {
        List {
            Section {
                TextField("Receipt.Name", text: $draft.name)
                    .textInputAutocapitalization(.words)
            }
            Section {
                Button {
                    isPersonPickerPresented = true
                } label: {
                    HStack {
                        Text("Receipt.Participants")
                            .bold()
                            .tint(.primary)
                        Spacer()
                        Text(NSLocalizedString("Receipt.Participants.Label", comment: "")
                            .replacingOccurrences(of: "%1", with: String(draft.participants().count)))
                        .lineLimit(1)
                        .truncationMode(.head)
                    }
                }
                .sheet(isPresented: $isPersonPickerPresented) {
                    NavigationStack {
                        PeoplePicker(title: "Receipt.Participants", selection: $draft.peopleWhoParticipated)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDetents([.medium])
                }
                Picker(selection: $draft.personWhoPaid) {
                    Text("Shared.NoSelection")
                        .tag(nil as Person?)
                    ForEach(draft.participants()) { person in
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
                ForEach($draft.receiptItems) { $item in
                    ReceiptItemAssignableRow(item: $item,
                                             peopleWhoParticipated: draft.participants(),
                                             placeholderText: "Receipt.ProductName")
                }
                .onDelete { indexSet in
                    draft.receiptItems.remove(atOffsets: indexSet)
                }
            } header: {
                HStack(alignment: .center, spacing: 4.0) {
                    ListSectionHeader(text: "Receipt.PurchasedItems")
                        .font(.body)
                    Spacer()
                    Button {
                        draft.receiptItems.append(
                            ReceiptDraft.Item(id: UUID().uuidString, name: "", price: 0.0,
                                              person: nil, dateAdded: Date.now))
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            Section {
                ForEach($draft.discountItems) { $item in
                    ReceiptItemEditableRow(item: $item,
                                           placeholderText: "Receipt.ItemName")
                }
                .onDelete { indexSet in
                    draft.discountItems.remove(atOffsets: indexSet)
                }
            } header: {
                HStack(alignment: .center, spacing: 4.0) {
                    ListSectionHeader(text: "Receipt.Discounts")
                        .font(.body)
                    Spacer()
                    Button {
                        draft.discountItems.append(
                            ReceiptDraft.Discount(name: "", price: 0.0, dateAdded: Date.now))
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            if draft.taxItems.isEmpty && taxRateCountry != "" {
                Section {
                    Text("Receipt.Tax.AutomaticallyCalculatedHint")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                } header: {
                    ListSectionHeader(text: "Receipt.Taxes")
                        .font(.body)
                }
            } else {
                Section {
                    ForEach($draft.taxItems) { $item in
                        ReceiptItemEditableRow(item: $item,
                                               placeholderText: "Receipt.ItemName")
                    }
                    .onDelete { indexSet in
                        draft.taxItems.remove(atOffsets: indexSet)
                    }
                } header: {
                    HStack(alignment: .center, spacing: 4.0) {
                        ListSectionHeader(text: "Receipt.Taxes")
                            .font(.body)
                        Spacer()
                        Button {
                            draft.taxItems.append(
                                ReceiptDraft.Tax(id: UUID().uuidString, name: "", price: 0.0,
                                                 dateAdded: Date.now))
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
        }
        .navigationTitle(draft.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                cancelButton
            }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarLeading)
            }
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    undoManager?.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!(undoManager?.canUndo ?? false))
                Button {
                    undoManager?.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!(undoManager?.canRedo ?? false))
            }
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
        .sensoryFeedback(.success, trigger: isSaveConfirmed)
        .interactiveDismissDisabled()
        .onChange(of: draft.peopleWhoParticipated) { _, _ in
            if let personWhoPaid = draft.personWhoPaid {
                if !draft.participants().contains(where: { $0.id == personWhoPaid.id }) {
                    draft.personWhoPaid = nil
                }
            }
        }
    }

    @ViewBuilder var cancelButton: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel) {
                cancelEditing()
            }
        } else {
            Button("Shared.Cancel") {
                cancelEditing()
            }
        }
    }

    @ViewBuilder var saveButton: some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm) {
                saveEditing()
            }
        } else {
            Button("Shared.Save") {
                saveEditing()
            }
        }
    }

    func cancelEditing() {
        if isNewReceipt {
            modelContext.delete(receipt)
            try? modelContext.save()
        }
        dismiss()
    }

    // swiftlint:disable function_body_length
    func saveEditing() {
        // Apply draft data to the model
        receipt.name = draft.name
        receipt.personWhoPaid = draft.personWhoPaid
        receipt.peopleWhoParticipated = draft.peopleWhoParticipated

        // Sync receipt items
        let existingItems = receipt.items(sorted: false)
        let draftItemIDs = Set(draft.receiptItems.map { $0.id })
        for existingItem in existingItems where !draftItemIDs.contains(existingItem.id) {
            receipt.receiptItems?.removeAll { $0.id == existingItem.id }
            modelContext.delete(existingItem)
        }
        for draftItem in draft.receiptItems {
            if let existingItem = existingItems.first(where: { $0.id == draftItem.id }) {
                existingItem.name = draftItem.name
                existingItem.price = draftItem.price
                existingItem.person = draftItem.person
            } else {
                let newItem = ReceiptItem(name: draftItem.name, price: draftItem.price, amount: 1)
                newItem.id = draftItem.id
                newItem.person = draftItem.person
                receipt.addReceiptItems(from: [newItem])
            }
        }

        // Sync discount items (replace all)
        for existingDiscount in receipt.discountItems(sorted: false) {
            modelContext.delete(existingDiscount)
        }
        receipt.discountItems = []
        for draftDiscount in draft.discountItems {
            let newDiscount = DiscountItem(name: draftDiscount.name, price: draftDiscount.price)
            receipt.addDiscountItems(from: [newDiscount])
        }

        // Sync tax items
        let existingTaxes = receipt.taxItems(sorted: false)
        let draftTaxIDs = Set(draft.taxItems.map { $0.id })
        for existingTax in existingTaxes where !draftTaxIDs.contains(existingTax.id) {
            receipt.taxItems?.removeAll { $0.id == existingTax.id }
            modelContext.delete(existingTax)
        }
        for draftTax in draft.taxItems {
            if let existingTax = existingTaxes.first(where: { $0.id == draftTax.id }) {
                existingTax.name = draftTax.name
                existingTax.price = draftTax.price
            } else {
                let newTax = TaxItem(name: draftTax.name, price: draftTax.price)
                newTax.id = draftTax.id
                receipt.addTaxItems(from: [newTax])
            }
        }

        if defaults.value(forKey: "MarkSelfPaid") == nil || markSelfPaid {
            receipt.setLenderItemsPaid()
        }
        // Calculate service charge first (needed for tax-above-service-charge)
        let serviceChargeAmount: Double
        if addTenPercent {
            serviceChargeAmount = receipt.sumOfItems() * 0.1
            if let serviceChargeItem = receipt.taxItems?.first(where: { $0.id == "AUTOTEN-\(receipt.id)" }) {
                serviceChargeItem.price = serviceChargeAmount
            } else {
                let automaticServiceCharge = TaxItem(name: NSLocalizedString("Receipt.ServiceCharge", comment: ""),
                                                     price: serviceChargeAmount)
                automaticServiceCharge.id = "AUTOTEN-\(receipt.id)"
                receipt.addTaxItems(from: [automaticServiceCharge])
            }
        } else {
            serviceChargeAmount = 0.0
        }
        // Calculate tax (supports tax above service charge)
        if taxRateCountry != "" {
            let taxBase: Double
            if taxAboveServiceCharge && addTenPercent {
                taxBase = serviceChargeAmount
            } else {
                taxBase = receipt.sumOfItems()
            }
            if let taxItem = receipt.taxItems?.first(where: { $0.id == "AUTOTAX-\(receipt.id)" }) {
                taxItem.price = taxBase * taxRate
            } else {
                let automaticTaxItem = TaxItem(name: "",
                                               price: taxBase * taxRate)
                automaticTaxItem.id = "AUTOTAX-\(receipt.id)"
                switch taxRateType {
                case "gst":
                    automaticTaxItem.name = NSLocalizedString("Receipt.Tax.GST", comment: "")
                case "vat":
                    automaticTaxItem.name = NSLocalizedString("Receipt.Tax.VAT", comment: "")
                default:
                    automaticTaxItem.name = ""
                }
                receipt.addTaxItems(from: [automaticTaxItem])
            }
        }
        try? modelContext.save()
        isSaveConfirmed = true
        MeloanApp.reloadWidget()
        dismiss()
    }
    // swiftlint:enable function_body_length
}
