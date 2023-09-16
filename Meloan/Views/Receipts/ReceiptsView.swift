//
//  ReceiptsView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptsView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query private var receipts: [Receipt]

    var body: some View {
        NavigationStack(path: $navigationManager.receiptsTabPath) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16.0) {
                    ForEach(receipts.sorted(by: { lhs, rhs in
                        lhs.name < rhs.name
                    })) { receipt in
                        ReceiptColumn(receipt: receipt)
                    }
                }
                .padding()
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Add sample data
                        // swiftlint:disable line_length
                        let person1 = Person(name: "Justin")
                        let person2 = Person(name: "Timothy")
                        let person3 = Person(name: "Dylon")
                        let receiptItem1 = ReceiptItem(name: "Steak Platter", price: 42.00, amount: 1)
                        let receiptItem2 = ReceiptItem(name: "Spaghetti Carbonara (Extra Sauce, Extra Cheese)", price: 12.00, amount: 1, purchasedBy: person1)
                        let receiptItem3 = ReceiptItem(name: "Fish & Chips", price: 11.00, amount: 1, purchasedBy: person2)
                        let receiptItem4 = ReceiptItem(name: "Sirloin Steak (Black Pepper Sauce)", price: 16.00, amount: 1, purchasedBy: person3)
                        let receiptItem5 = ReceiptItem(name: "Ice Water", price: 1.00, amount: 3)
                        let discountItem = DiscountItem(name: "Card Discount", price: 6.00)
                        let taxItem1 = TaxItem(name: "Service Charge", price: 8.10)
                        let taxItem2 = TaxItem(name: "Daylight Robbery", price: 6.48)
                        let receipt = Receipt(name: "Johnny's Restaurant 2023/8/10", paidBy: person1)
                        // swiftlint:enable line_length
                        modelContext.insert(person1)
                        modelContext.insert(person2)
                        modelContext.insert(person3)
                        modelContext.insert(receiptItem1)
                        modelContext.insert(receiptItem2)
                        modelContext.insert(receiptItem3)
                        modelContext.insert(receiptItem4)
                        modelContext.insert(receiptItem5)
                        modelContext.insert(discountItem)
                        modelContext.insert(taxItem1)
                        modelContext.insert(taxItem2)
                        receipt.addReceiptItems(from: [receiptItem1, receiptItem2, receiptItem3, receiptItem4, receiptItem5])
                        receipt.addDiscountItems(from: [discountItem])
                        receipt.addTaxItems(from: [taxItem1, taxItem2])
                        modelContext.insert(receipt)
                    } label: {
                        Image(systemName: "plus")
                    }
                    EditButton()
                }
            }
            .navigationTitle("ViewTitle.Receipts")
        }
    }
}
