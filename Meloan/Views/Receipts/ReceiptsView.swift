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
    @State var isCreatingReceipt: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.receiptsTabPath) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16.0) {
                    ForEach(receipts.sorted(by: { lhs, rhs in
                        lhs.name < rhs.name
                    })) { receipt in
                        ReceiptColumn(receipt: receipt)
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(receipt)
                                } label: {
                                    Label("Shared.Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            // Add sample data
                            // swiftlint:disable line_length
                            let person1 = Person(name: "Akagi", photo: UIImage(named: "Akagi")!.pngData())
                            let person2 = Person(name: "Muramoto", photo: UIImage(named: "Muramoto")!.pngData())
                            let person3 = Person(name: "Kuroko", photo: UIImage(named: "Kuroko")!.pngData())
                            let receiptItem1 = ReceiptItem(name: "Steak Platter", price: 42.00, amount: 1)
                            let receiptItem2 = ReceiptItem(name: "Spaghetti Carbonara (Extra Sauce, Extra Cheese)", price: 12.00, amount: 1, purchasedBy: person1)
                            let receiptItem3 = ReceiptItem(name: "Fish & Chips", price: 11.00, amount: 1, purchasedBy: person2)
                            let receiptItem4 = ReceiptItem(name: "Sirloin Steak (Black Pepper Sauce)", price: 16.00, amount: 1, purchasedBy: person3)
                            let receiptItem5 = ReceiptItem(name: "Ice Water", price: 1.00, amount: 3)
                            let discountItem = DiscountItem(name: "Card Discount", price: 6.00)
                            let taxItem1 = TaxItem(name: "Service Charge", price: 8.10)
                            let taxItem2 = TaxItem(name: "GST", price: 6.48)
                            let receipt = Receipt(name: "Team Dinner at Johnny's Diner")
                            // swiftlint:enable line_length
                            receipt.addReceiptItems(from: [receiptItem1, receiptItem2, receiptItem3,
                                                           receiptItem4, receiptItem5])
                            receipt.addDiscountItems(from: [discountItem])
                            receipt.addTaxItems(from: [taxItem1, taxItem2])
                            receipt.setPersonWhoPaid(to: person1)
                            modelContext.insert(receipt)
                            try? modelContext.save()
                        } label: {
                            Text("Shared.CreateSampleData")
                        }
                        Button {
                            isCreatingReceipt = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isCreatingReceipt) {
                ReceiptCreator {
                    isCreatingReceipt = false
                }
                .interactiveDismissDisabled()
            }
            .navigationTitle("ViewTitle.Receipts")
        }
    }
}
