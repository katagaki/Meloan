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
import UIKit

struct ReceiptEditor: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @AppStorage(wrappedValue: true, "MarkSelfPaid", store: defaults) var markSelfPaid: Bool
    @AppStorage(wrappedValue: 0.0, "TaxRate", store: defaults) var taxRate: Double
    @AppStorage(wrappedValue: "", "TaxRateCountry", store: defaults) var taxRateCountry: String
    @AppStorage(wrappedValue: "", "TaxRateType", store: defaults) var taxRateType: String
    @AppStorage(wrappedValue: false, "AddTenPercent", store: defaults) var addTenPercent: Bool
    @State var taxRates: TaxRate.List = Bundle.main.decode(TaxRate.List.self, from: "TaxRates.json")!
    @State var widgetReloadDebouncer = PassthroughSubject<String, Never>()
    @State var isPersonPickerPresented: Bool = false
    @State var receipt: Receipt

    var body: some View {
        List {
            Section {
                TextField("Receipt.Name", text: $receipt.name)
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
                            .replacingOccurrences(of: "%1", with: String(receipt.participants().count)))
                        .lineLimit(1)
                        .truncationMode(.head)
                    }
                }
                .sheet(isPresented: $isPersonPickerPresented) {
                    NavigationStack {
                        PeoplePicker(title: "Receipt.Participants", selection: $receipt.peopleWhoParticipated)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDetents([.medium])
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
            if receipt.taxItems().count == 0 && taxRateCountry != "" {
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
                        ListSectionHeader(text: "Receipt.Taxes")
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
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle(receipt.name)
        .navigationBarTitleDisplayMode(.inline)
        // TODO: Implement manual saving
        .safeAreaInset(edge: .top) {
            HStack(alignment: .center, spacing: 8.0) {
                Image(systemName: "info.circle.fill")
                    .font(.subheadline)
                Text("Shared.AutoSaving")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Material.bar)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 1/3)
                    .foregroundColor(.primary.opacity(0.2))
            }
        }
        .toolbar {
            if UIDevice.current.userInterfaceIdiom == .pad {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            if defaults.value(forKey: "MarkSelfPaid") == nil || markSelfPaid {
                receipt.setLenderItemsPaid()
            }
            if taxRateCountry != "" {
                if let taxItem = receipt.taxItems?.first(where: { $0.id == "AUTOTAX-\(receipt.id)" }) {
                    taxItem.price = receipt.sumOfItems() * taxRate
                } else {
                    let automaticTaxItem = TaxItem(name: "",
                                                   price: receipt.sumOfItems() * taxRate)
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
            if addTenPercent {
                if let serviceChargeItem = receipt.taxItems?.first(where: { $0.id == "AUTOTEN-\(receipt.id)" }) {
                    serviceChargeItem.price = receipt.sumOfItems() * 0.1
                } else {
                    let automaticServiceCharge = TaxItem(name: NSLocalizedString("Receipt.ServiceCharge", comment: ""),
                                                         price: receipt.sumOfItems() * 0.1)
                    automaticServiceCharge.id = "AUTOTEN-\(receipt.id)"
                    receipt.addTaxItems(from: [automaticServiceCharge])
                }
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
