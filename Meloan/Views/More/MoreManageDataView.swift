//
//  MoreManageDataView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/22.
//

import Komponents
import SwiftData
import SwiftUI

struct MoreManageDataView: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query var people: [Person]
    @Query var receipts: [Receipt]
    @State var isDeleteConfirming: Bool = false
    @State var isSettingsResetConfirming: Bool = false

    var body: some View {
        List {
            Section {
                Button {
                    createSampleData()
                } label: {
                    Text("More.Data.SampleData.Create")
                }
            } header: {
                ListSectionHeader(text: "More.Data.SampleData")
                    .font(.body)
            } footer: {
                Text("More.Data.SampleData.Description")
                    .font(.body)
            }
        }
        .navigationTitle("ViewTitle.Data")
    }

    func createSampleData() {
        let person1 = Person(name: NSLocalizedString("SampleData.Akagi", comment: ""),
                             photo: UIImage(named: "Akagi")!.pngData())
        let person2 = Person(name: NSLocalizedString("SampleData.Muramoto", comment: ""),
                             photo: UIImage(named: "Muramoto")!.pngData())
        let person3 = Person(name: NSLocalizedString("SampleData.Kuroko", comment: ""),
                             photo: UIImage(named: "Kuroko")!.pngData())
        let receiptItem1 = ReceiptItem(name: NSLocalizedString("SampleData.Item1", comment: ""),
                                       price: 42.00, amount: 1)
        let receiptItem2 = ReceiptItem(name: NSLocalizedString("SampleData.Item2", comment: ""),
                                       price: 12.00, amount: 1)
        let receiptItem3 = ReceiptItem(name: NSLocalizedString("SampleData.Item3", comment: ""),
                                       price: 11.00, amount: 1)
        let receiptItem4 = ReceiptItem(name: NSLocalizedString("SampleData.Item4", comment: ""),
                                       price: 16.00, amount: 1)
        let receiptItem5 = ReceiptItem(name: NSLocalizedString("SampleData.Item5", comment: ""),
                                       price: 1.00, amount: 3)
        let discountItem = DiscountItem(name: NSLocalizedString("SampleData.Discount", comment: ""),
                                        price: 6.00)
        let taxItem1 = TaxItem(name: NSLocalizedString("SampleData.TaxItem1", comment: ""),
                               price: 8.10)
        let taxItem2 = TaxItem(name: NSLocalizedString("SampleData.TaxItem2", comment: ""),
                               price: 6.48)
        let receipt = Receipt(name: NSLocalizedString("SampleData.ReceiptName", comment: ""))
        modelContext.insert(person1)
        modelContext.insert(person2)
        modelContext.insert(person3)
        receiptItem2.setPurchaser(to: person1)
        receiptItem3.setPurchaser(to: person2)
        receiptItem4.setPurchaser(to: person3)
        receipt.addReceiptItems(from: [receiptItem1, receiptItem2, receiptItem3,
                                       receiptItem4, receiptItem5])
        receipt.addDiscountItems(from: [discountItem])
        receipt.addTaxItems(from: [taxItem1, taxItem2])
        receipt.setPersonWhoPaid(to: person1)
        receipt.addPeopleWhoParticipated(from: [person1, person2, person3])
        modelContext.insert(receipt)
    }
}
