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

struct ReceiptsView: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Receipt.dateAdded, order: .reverse, animation: .snappy.speed(2)) var receipts: [Receipt]
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
                            ZStack(alignment: .bottom) {
                                VStack(alignment: .center, spacing: 16.0) {
                                    ActionButton(text: "Shared.Edit", icon: "Receipt.Edit", isPrimary: false) {
                                        navigationManager.push(ViewPath.receiptEditor(receipt: receipt), for: .receipts)
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
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(receipt)
                                        } label: {
                                            Label("Shared.Delete", image: "Delete")
                                        }
                                    }
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
            .navigationTitle("ViewTitle.Receipts")
        }
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
            if gesture.predictedEndLocation.y <= -expectedOffset ||
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
