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
                LazyHStack(alignment: .top, spacing: 20.0) {
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
                .padding(20.0)
            }
            .background(Color(uiColor: UIColor.systemGroupedBackground))
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .receiptDetail(let receipt): ReceiptDetailView(receipt: receipt)
                default: Color.clear
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            isCreatingReceipt = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .popoverTip(ReceiptsTip(), arrowEdge: .top)
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
