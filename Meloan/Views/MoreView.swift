//
//  MoreView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftData
import SwiftUI

struct MoreView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Person.name) private var people: [Person]

    @State var isDeleteConfirming: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.moreTabPath) {
            MoreList(repoName: "katagaki/Meloan", viewPath: ViewPath.moreAttributions) {
                // TODO: Add setting options for default tax rate, currency, etc
                Section {
                    Button {
                        createSampleData()
                    } label: {
                        Text("More.Data.CreateSampleData")
                    }
                    Button {
                        isDeleteConfirming = true
                    } label: {
                        Text("More.Data.DeleteAll")
                            .foregroundStyle(.red)
                    }
                } header: {
                    ListSectionHeader(text: "More.Data")
                        .font(.body)
                }
            }
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .moreAttributions: LicensesView(licenses: [
                    License(libraryName: "ConfettiSwiftUI", text:
"""
MIT License

Copyright (c) 2020 Simon Bachmann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""")
                ])
                default: Color.clear
                }
            }
        }
        .alert("Alert.DeleteAll.Title", isPresented: $isDeleteConfirming) {
            Button(role: .destructive) {
                deleteAllData()
                navigationManager.popAll()
            } label: {
                Text("Shared.Yes")
            }
            Button(role: .cancel) { } label: {
                Text("Shared.No")
            }
        } message: {
            Text("Alert.DeleteAll.Text")
        }
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

    func deleteAllData() {
        do {
            try modelContext.delete(model: ReceiptItem.self)
            try modelContext.delete(model: DiscountItem.self)
            try modelContext.delete(model: TaxItem.self)
            try modelContext.delete(model: Receipt.self)
            for person in people where person.id != "ME" {
                modelContext.delete(person)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
