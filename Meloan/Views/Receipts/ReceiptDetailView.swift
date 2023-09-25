//
//  ReceiptDetailView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import ConfettiSwiftUI
import Komponents
import SwiftUI

// swiftlint:disable type_body_length
struct ReceiptDetailView: View {

    @State var receipt: Receipt
    @State var confettiCounter: Int = 0
    @State var isSharing: Bool = false

    var body: some View {
        List {
            Section {
                HStack(alignment: .center, spacing: 8.0) {
                    ActionButton(text: "Receipt.ExportPDF", icon: "PDF", isPrimary: false) {
                        isSharing = true
                    }
                    ShareLink(item: createImageToShare(),
                              preview: SharePreview(receipt.name, image: createImageToShare())) {
                        HStack(alignment: .center, spacing: 4.0) {
                            Image("Image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18.0, height: 18.0)
                            Text("Receipt.ExportImage")
                                .bold()
                        }
                        .frame(minHeight: 24.0)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(RoundedRectangle(cornerRadius: 99))
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            receiptDetails()
        }
        .confettiCannon(counter: $confettiCounter, num: Int(receipt.sum()), rainHeight: 1000.0, radius: 500.0)
        .sheet(isPresented: $isSharing, content: {
            PDFExporterView(receipt: receipt)
                .presentationDragIndicator(.visible)
        })
        .navigationTitle(receipt.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // swiftlint:disable function_body_length
    @ViewBuilder
    func receiptDetails() -> some View {
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
                                    .multilineTextAlignment(.leading)
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

    @ViewBuilder
    func receiptDetailsForExport() -> some View {
        VStack(alignment: .leading, spacing: 16.0) {
            HStack(alignment: .center, spacing: 16.0) {
                Text(receipt.name)
                    .font(.system(size: 36.0))
                    .bold()
                Spacer()
                Image("PDF.Watermark")
                    .resizable()
                    .frame(width: 40.0, height: 40.0)
            }
            if !receipt.items().isEmpty {
                Divider()
                Text(NSLocalizedString("Receipt.PurchasedItems", comment: ""))
                    .font(.system(size: 28.0))
                    .bold()
                ForEach(receipt.items()) { item in
                    VStack(alignment: .leading, spacing: 8.0) {
                        ReceiptItemRow(name: item.name, price: item.price, priceFontSize: 16.0)
                            .strikethrough(item.paid)
                        HStack(alignment: .center, spacing: 8.0) {
                            if let person = item.person {
                                Group {
                                    if let data = person.photo, let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                    } else {
                                        Image("Profile.Generic")
                                            .resizable()
                                    }
                                }
                                .frame(width: 16.0, height: 16.0)
                                .clipShape(Circle())
                                Text(person.name)
                                    .foregroundStyle(.gray)
                            } else {
                                Image("Profile.Shared.Circle")
                                    .resizable()
                                    .frame(width: 16.0, height: 16.0)
                                Text(NSLocalizedString("Shared.Shared", comment: ""))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
            if !receipt.discountItems().isEmpty {
                Divider()
                Text(NSLocalizedString("Receipt.Discounts", comment: ""))
                    .font(.system(size: 28.0))
                    .bold()
                ForEach(receipt.discountItems()) { item in
                    ReceiptItemRow(name: item.name, price: item.price, priceFontSize: 16.0)
                }
            }
            if !receipt.taxItems().isEmpty {
                Divider()
                Text(NSLocalizedString("Receipt.Taxes", comment: ""))
                    .font(.system(size: 28.0))
                    .bold()
                ForEach(receipt.taxItems()) { item in
                    ReceiptItemRow(name: item.name, price: item.price, priceFontSize: 16.0)
                }
            }
            Divider()
            HStack(alignment: .center, spacing: 4.0) {
                Text(NSLocalizedString("Receipt.Total.BeforeTax", comment: ""))
                Spacer()
                Text(format(receipt.sumOfItems()))
                    .monospaced()
            }
            HStack(alignment: .center, spacing: 4.0) {
                Text(NSLocalizedString("Receipt.Total.AfterTax", comment: ""))
                Spacer()
                Text(format(receipt.sum()))
                    .monospaced()
            }
            .bold()
        }
        .font(.system(size: 16.0))
        .padding()
        .foregroundStyle(.primary)
        .background(.background)
    }
    // swiftlint:enable function_body_length

    @MainActor
    func createImageToShare() -> Image {
        let renderer = ImageRenderer(content: receiptDetailsForExport())
        renderer.scale = 3.0
        if let image = renderer.cgImage {
            return Image(uiImage: UIImage(cgImage: image))
        } else {
            fatalError("Could not export image.")
        }
    }
}
// swiftlint:enable type_body_length
