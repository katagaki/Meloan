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

    @EnvironmentObject var settings: SettingsManager
    @State var receipt: Receipt
    @State var confettiCounter: Int = 0

    var body: some View {
        List {
            Section {
                ForEach(receipt.participants(sortPayerOnTop: true)) { person in
                    PersonRow(person: person, isPersonWhoPaid: person.id == receipt.personWhoPaid?.id ?? "")
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
                        Text(settings.format(receipt.sumOfItems()))
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
                    ListSectionHeader(text: "Receipt.Tax")
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
        .navigationTitle(receipt.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
