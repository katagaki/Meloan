//
//  ReceiptDetailView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import ConfettiSwiftUI
import Komponents
import SwiftUI

struct ReceiptDetailView: View {

    @State var receipt: Receipt
    @State var confettiCounter: Int = 0
    @State var isSharing: Bool = false

    var body: some View {
        List {
            if let personWhoPaid = receipt.personWhoPaid {
                Section {
                    NavigationLink(value: ViewPath.personDetail(person: personWhoPaid)) {
                        HStack(alignment: .center, spacing: 16.0) {
                            ListRow(image: "ListIcon.Payer", title: "Receipt.Payer")
                            Spacer()
                            PersonRow(person: personWhoPaid)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                ForEach(receipt.borrowers()) { person in
                    NavigationLink(value: ViewPath.personDetail(person: person)) {
                        PersonRow(person: person)
                    }
                }
            } header: {
                ListSectionHeader(text: "Receipt.Participants")
                    .font(.body)
            }
            if !receipt.items().isEmpty {
                Section {
                    ForEach(receipt.items()) { item in
                        if let person = item.person {
                            Button {
                                item.paid.toggle()
                                MeloanApp.reloadWidget()
                                if receipt.isPaid() {
                                    confettiCounter += 1
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Group {
                                        if let data = person.photo, let image = UIImage(data: data) {
                                            Image(uiImage: image)
                                                .resizable()
                                        } else {
                                            Image("Profile.Generic")
                                                .resizable()
                                        }
                                    }
                                    .frame(width: 32.0, height: 32.0)
                                    .clipShape(Circle())
                                    ReceiptItemRow(name: item.name, price: item.price)
                                        .strikethrough(item.paid)
                                }
                            }
                        } else {
                            Menu {
                                ForEach(receipt.participants()) { person in
                                    Button {
                                        if item.personHasPaid(person) {
                                            item.removePersonWhoPaid(withID: person.id)
                                            item.paid = false
                                        } else {
                                            item.addPersonWhoPaid(from: [person])
                                            item.paid =  receipt.participants().count == item.peopleWhoPaid?.count
                                        }
                                        if receipt.isPaid() {
                                            confettiCounter += 1
                                        }
                                    } label: {
                                        HStack {
                                            if item.personHasPaid(person) {
                                                Image(systemName: "checkmark")
                                            }
                                            PersonRow(person: person)
                                        }
                                    }
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image("Profile.Shared")
                                        .resizable()
                                    .frame(width: 32.0, height: 32.0)
                                    .clipShape(Circle())
                                    ReceiptItemRow(name: item.name, price: item.price)
                                        .strikethrough(item.paid)
                                }
                            }
                        }
                    }
                } header: {
                    ListSectionHeader(text: "Receipt.PurchasedItems")
                        .font(.body)
                        .popoverTip(ReceiptMarkPaidTip())
                } footer: {
                    HStack(alignment: .center, spacing: 4.0) {
                        Text("Receipt.Total")
                            .font(.body)
                        Spacer()
                        Text(format(receipt.sumOfItems()))
                            .font(.system(size: 14.0))
                            .monospaced()
                    }
                    .bold()
                    .foregroundStyle(.primary)
                }
            }
            if !receipt.discountItems().isEmpty {
                Section {
                    ForEach(receipt.discountItems()) { item in
                        ReceiptItemRow(name: item.name, price: item.price)
                    }
                } header: {
                    ListSectionHeader(text: "Receipt.Discounts")
                        .font(.body)
                }
            }
            if !receipt.taxItems().isEmpty {
                Section {
                    ForEach(receipt.taxItems()) { item in
                        ReceiptItemRow(name: item.name, price: item.price)
                    }
                } header: {
                    ListSectionHeader(text: "Receipt.Taxes")
                        .font(.body)
                } footer: {
                    HStack(alignment: .center, spacing: 4.0) {
                        Text("Receipt.Tax.Detail")
                            .font(.body)
                        Spacer()
                        Text("\(Int(receipt.taxRate() * 100), specifier: "%d")%")
                            .font(.system(size: 14.0))
                            .monospaced()
                    }
                    .bold()
                    .foregroundStyle(.primary)
                }
            }
        }
        .confettiCannon(counter: $confettiCounter, num: Int(receipt.sum()), rainHeight: 1000.0, radius: 500.0)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSharing = true
                } label: {
                    Image("PDF")
                }
            }
        }
        .sheet(isPresented: $isSharing, content: {
            PDFExporterView(receipt: receipt)
                .presentationDragIndicator(.visible)
        })
        .navigationTitle(receipt.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
