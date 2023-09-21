//
//  ReceiptsView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptsView: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Receipt.dateAdded, order: .reverse, animation: .snappy.speed(2)) var receipts: [Receipt]

    var body: some View {
        NavigationStack(path: $navigationManager.receiptsTabPath) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 20.0) {
                    ForEach(receipts) { receipt in
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
                .padding(20.0)
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .receiptDetail(let receipt): ReceiptDetailView(receipt: receipt)
                case .receiptEditor(let receipt): ReceiptEditor(receipt: receipt)
                default: Color.clear
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            debugPrint("Attempting to reload data...")
                            Task { @MainActor in
                                _ = try? modelContext.fetch(FetchDescriptor<ReceiptItem>())
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise.circle")
                        }
                        Button {
                            let receipt = Receipt(name: NSLocalizedString("Receipt.Create.Name.Default", comment: ""))
                            modelContext.insert(receipt)
                            navigationManager.push(ViewPath.receiptEditor(receipt: receipt), for: .receipts)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .popoverTip(ReceiptsTip(), arrowEdge: .top)
                    }
                }
            }
            .navigationTitle("ViewTitle.Receipts")
        }
    }
}
