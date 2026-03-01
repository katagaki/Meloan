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

    // State variables
    @State var receiptBeingEdited: Receipt?
    @State var isNewReceipt: Bool = false

    // Filter variables
    @AppStorage(wrappedValue: false, "HidePaidReceipts", store: defaults) var hidePaid: Bool
    @AppStorage(wrappedValue: "", "FilterPayerID", store: defaults) var filterPayerID: String
    @AppStorage(wrappedValue: true, "FilterShowIPaid", store: defaults) var filterShowIPaid: Bool
    @AppStorage(wrappedValue: true, "FilterShowOthersPaid", store: defaults) var filterShowOthersPaid: Bool
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
                            if shouldShowReceipt(receipt) {
                                ZStack(alignment: .bottom) {
                                    VStack(alignment: .center, spacing: 16.0) {
                                        ActionButton(text: "Shared.Edit", icon: "Edit", isPrimary: false) {
                                            isNewReceipt = false
                                            receiptBeingEdited = receipt
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
                                        .mask {
                                            VStack(spacing: 0.0) {
                                                let progress = fadeProgress(for: receipt)
                                                LinearGradient(
                                                    colors: [.clear, .black],
                                                    startPoint: .top,
                                                    endPoint: UnitPoint(x: 0.5, y: min(progress * 2.0, 1.0))
                                                )
                                                .frame(height: progress > 0.0 ? 24.0 : 0.0)
                                                Rectangle()
                                            }
                                        }
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
                case .personDetail(let person): PeopleDetailView(person: person)
                default: Color.clear
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Toggle(isOn: $hidePaid.animation(.snappy.speed(2))) {
                            Text("Receipts.HidePaidReceipts")
                                .bold()
                        }
                        Divider()
                        Toggle(isOn: $filterShowIPaid.animation(.snappy.speed(2))) {
                            Text("Receipts.Filter.IPaid")
                        }
                        Toggle(isOn: $filterShowOthersPaid.animation(.snappy.speed(2))) {
                            Text("Receipts.Filter.OthersPaid")
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
                                filterShowIPaid = true
                                filterShowOthersPaid = true
                            }
                        } label: {
                            Text("Shared.Filter.Reset")
                        }
                    } label: {
                        Label("Shared.Filter",
                              systemImage: "line.3.horizontal.decrease")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let receipt = Receipt(name: NSLocalizedString("Receipt.Create.Name.Default", comment: ""))
                        modelContext.insert(receipt)
                        isNewReceipt = true
                        receiptBeingEdited = receipt
                    } label: {
                        Label("Shared.Create", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $receiptBeingEdited, content: { receipt in
                NavigationStack {
                    ReceiptEditor(receipt: receipt, isNewReceipt: isNewReceipt)
                }
            })
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

    func shouldShowReceipt(_ receipt: Receipt) -> Bool {
        // Hide paid receipts filter
        if hidePaid && receipt.isPaid() {
            return false
        }
        // Specific payer filter
        if let filterPayer = filterPayer, filterPayer != receipt.personWhoPaid {
            return false
        }
        // "I paid" / "Others paid" filter
        let mePersonID = "ME"
        let iPaid = receipt.personWhoPaid?.id == mePersonID
        if !filterShowIPaid && iPaid {
            return false
        }
        if !filterShowOthersPaid && !iPaid {
            return false
        }
        return true
    }

    func fadeProgress(for receipt: Receipt) -> CGFloat {
        let offset = offsets[receipt]?.height ?? 0.0
        guard offset < 0.0, expectedOffset > 0.0 else { return 0.0 }
        return min(-offset / expectedOffset, 1.0)
    }

    func handleChange(of gesture: DragGesture.Value, for receipt: Receipt) {
        if offsets[receipt] == nil { offsets[receipt] = .zero }
        if previousOffsets[receipt] == nil { previousOffsets[receipt] = .zero }
        let baseOffset = previousOffsets[receipt]?.height ?? 0.0
        let rawOffset = baseOffset + gesture.translation.height
        if rawOffset > 0.0 {
            // Rubber-band above rest position
            offsets[receipt]!.height = rubberBand(rawOffset, limit: expectedOffset)
        } else if rawOffset < -expectedOffset {
            // Rubber-band below the revealed position
            let excess = rawOffset + expectedOffset
            offsets[receipt]!.height = -expectedOffset + rubberBand(excess, limit: expectedOffset)
        } else {
            // Normal range between 0 and -expectedOffset
            offsets[receipt]!.height = rawOffset
        }
    }

    func handleEndOfGesture(of gesture: DragGesture.Value, for receipt: Receipt) {
        guard offsets[receipt] != nil else { return }
        let currentOffset = offsets[receipt]!.height
        let velocity = gesture.velocity.height
        let projectedOffset = currentOffset + velocity * 0.15
        let midpoint = -expectedOffset / 2.0
        if projectedOffset <= midpoint {
            withAnimation(.snappy.speed(2)) {
                offsets[receipt]!.height = -expectedOffset
            }
        } else {
            withAnimation(.snappy.speed(2)) {
                offsets[receipt]!.height = 0.0
            }
        }
        previousOffsets[receipt] = offsets[receipt]
    }

    func rubberBand(_ offset: CGFloat, limit: CGFloat) -> CGFloat {
        let clamped = max(limit, 1.0)
        return offset * clamped / (abs(offset) + clamped)
    }
}
// swiftlint:enable type_body_length
