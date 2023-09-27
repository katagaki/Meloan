//
//  ReceiptsView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftData
import SwiftUI
import TipKit
import UIKit

// swiftlint:disable type_body_length
struct ReceiptsView: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Receipt.dateAdded, order: .reverse, animation: .snappy.speed(2)) var receipts: [Receipt]
    @Query(sort: \Person.name) var people: [Person]

    // Filter variables
    @AppStorage(wrappedValue: false, "HidePaidReceipts", store: defaults) var hidePaid: Bool
    @AppStorage(wrappedValue: "", "FilterPayerID", store: defaults) var filterPayerID: String
    @State var filterPayer: Person?

    // Gesture variables
    @State var offsets: [Receipt: CGSize] = [:]
    @State var previousOffsets: [Receipt: CGSize] = [:]
    @State var expectedOffset: CGFloat = 0.0

    var body: some View {
        NavigationStack(path: $navigationManager.receiptsTabPath) {
            VStack(alignment: .leading, spacing: 0.0) {
                Group {
                    if receipts.count > 0 {
                        TipView(ReceiptDeleteAndEditTip())
                    } else {
                        TipView(ReceiptsTip())
                    }
                }
                .padding(20.0)
                .background(.background)
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 20.0) {
                        ForEach(receipts) { receipt in
                            if (!hidePaid || !receipt.isPaid()) &&
                                (filterPayer == nil || filterPayer == receipt.personWhoPaid) {
                                ZStack(alignment: .bottom) {
                                    VStack(alignment: .center, spacing: 16.0) {
                                        ActionButton(text: "Shared.Edit", icon: "Edit", isPrimary: false) {
                                            navigationManager.push(ViewPath.receiptEditor(receipt: receipt),
                                                                   for: .receipts)
                                        }
                                        ActionButton(text: "Shared.Delete", icon: "Delete", isPrimary: true) {
                                            withAnimation(.snappy.speed(2)) {
                                                modelContext.delete(receipt)
                                            }
                                        }
                                        .tint(.red)
                                    }
                                    .padding(16.0)
                                    .overlay {
                                        GeometryReader { metrics in
                                            Color.clear
                                                .onAppear {
                                                    expectedOffset = metrics.size.height
                                                }
                                        }
                                    }
                                    ReceiptColumn(receipt: receipt)
                                        .offset(y: offsets[receipt]?.height ?? 0.0)
                                        .gesture(
                                            DragGesture(minimumDistance: 20)
                                                .onChanged { gesture in
                                                    handleChange(of: gesture, for: receipt)
                                                }
                                                .onEnded { gesture in
                                                    handleEndOfGesture(of: gesture, for: receipt)
                                                }
                                        )
                                }
                            }
                        }
                    }
                    .padding(20.0)
                    .onTapGesture {
                        withAnimation {
                            offsets.keys.forEach { key in
                                offsets.updateValue(.zero, forKey: key)
                            }
                            previousOffsets.keys.forEach { key in
                                previousOffsets.updateValue(.zero, forKey: key)
                            }
                        }
                    }
                }
                .scrollClipDisabled()
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .receiptDetail(let receipt): ReceiptDetailView(receipt: receipt)
                case .receiptEditor(let receipt): ReceiptEditor(receipt: receipt)
                case .personDetail(let person): PeopleDetailView(person: person)
                default: Color.clear
                }
            })
            .safeAreaInset(edge: .top, spacing: 0.0) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: 0.0)
                    .background(.regularMaterial)
                    .overlay(Rectangle().frame(width: nil,
                                               height: 1/3,
                                               alignment: .bottom).foregroundColor(.primary.opacity(0.3)),
                             alignment: .bottom)
            }
            .safeAreaInset(edge: .bottom, spacing: 0.0) {
                HStack(alignment: .center, spacing: 16.0) {
                    Spacer()
                    Menu {
                        Toggle(isOn: $hidePaid.animation(.snappy.speed(2))) {
                            Text("Receipts.HidePaidReceipts")
                                .bold()
                        }
                        Divider()
                        Menu {
                            if let mePerson = people.first(where: { $0.id == "ME" }) {
                                Button {
                                    filterPayer = mePerson
                                } label: {
                                    personRowWithCheck(person: mePerson)
                                }
                            }
                            ForEach(people.filter({ $0.id != "ME" })) { person in
                                Button {
                                    filterPayer = person
                                } label: {
                                    personRowWithCheck(person: person)
                                }
                            }
                        } label: {
                            Text("Receipt.Payer")
                        }
                        Divider()
                        Button(role: .destructive) {
                            withAnimation(.snappy.speed(2)) {
                                hidePaid = false
                                filterPayer = nil
                            }
                        } label: {
                            Text("Shared.Filter.Reset")
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 4.0) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18.0, height: 18.0)
                            Text("Shared.Filter")
                                .bold()
                        }
                        .padding(.all, 2.0)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(isFilterActive() ? .white : .accent)
                    .padding([.leading, .trailing], 8.0)
                    .padding([.top, .bottom], 4.0)
                    .background {
                        if isFilterActive() {
                            RoundedRectangle(cornerRadius: 99)
                                .foregroundStyle(.accent)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .overlay(Rectangle().frame(width: nil,
                                           height: 1/3,
                                           alignment: .top).foregroundColor(.primary.opacity(0.3)),
                         alignment: .top)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            let receipt = Receipt(name: NSLocalizedString("Receipt.Create.Name.Default", comment: ""))
                            modelContext.insert(receipt)
                            navigationManager.push(ViewPath.receiptEditor(receipt: receipt), for: .receipts)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .onDisappear {
                withAnimation(.snappy.speed(2)) {
                    offsets.keys.forEach { key in
                        offsets.updateValue(CGSize.zero, forKey: key)
                    }
                    previousOffsets.keys.forEach { key in
                        previousOffsets.updateValue(CGSize.zero, forKey: key)
                    }
                }
            }
            .onAppear {
                if let filterPayer = people.first(where: { $0.id == filterPayerID }) {
                    self.filterPayer = filterPayer
                }
            }
            .onChange(of: filterPayer, { _, _ in
                filterPayerID = filterPayer?.id ?? ""
            })
            .navigationTitle("ViewTitle.Receipts")
        }
    }

    @ViewBuilder
    func personRowWithCheck(person: Person) -> some View {
        Text(person.name)
        if filterPayer == person {
            Image(systemName: "checkmark")
        } else {
            if let photo = person.photo, let image = UIImage(data: photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("Profile.Generic.Circle")
                    .resizable()
            }
        }
    }

    func isFilterActive() -> Bool {
        return hidePaid || filterPayer != nil
    }

    func handleChange(of gesture: DragGesture.Value, for receipt: Receipt) {
        if offsets[receipt] == nil { offsets[receipt] = .zero }
        if previousOffsets[receipt] == nil { previousOffsets[receipt] = .zero }
        if let previousOffset = previousOffsets[receipt] {
            let translationHeight = gesture.translation.height
            let expectedTranslation = previousOffset.height + translationHeight
            var newOffset = CGSize(width: 0.0, height: previousOffset.height)
            if expectedTranslation >= 0.0 {
                if previousOffset.height <= -expectedOffset {
                    newOffset.height = (translationHeight - expectedOffset) / 2.0
                } else {
                    newOffset.height = translationHeight / 2.0
                }
            } else if expectedTranslation <= -expectedOffset {
                if previousOffset.height <= -expectedOffset {
                    newOffset.height = -expectedOffset + translationHeight / 2.0
                } else {
                    newOffset.height = -expectedOffset + (translationHeight + expectedOffset) / 2.0
                }
            } else {
                newOffset.height += translationHeight
            }
            offsets.updateValue(newOffset, forKey: receipt)
        }
    }

    func handleEndOfGesture(of gesture: DragGesture.Value, for receipt: Receipt) {
        if let offset = offsets[receipt] {
            if (previousOffsets[receipt]?.height ?? 0.0) + gesture.predictedEndTranslation.height <= -expectedOffset ||
                offset.height <= -expectedOffset {
                withAnimation(.snappy.speed(2)) {
                    offsets[receipt]!.height = -expectedOffset
                }
            } else {
                withAnimation(.snappy.speed(2)) {
                    offsets[receipt]!.height = 0.0
                }
            }
        }
        previousOffsets[receipt] = offsets[receipt]
    }
}
// swiftlint:enable type_body_length
