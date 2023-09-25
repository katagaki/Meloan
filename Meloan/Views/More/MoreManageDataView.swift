//
//  MoreManageDataView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/22.
//

import CloudKit
import CloudKitSyncMonitor
import Komponents
import SwiftData
import SwiftUI

struct MoreManageDataView: View {

    @Environment(\.modelContext) var modelContext
    @ObservedObject var syncMonitor = SyncMonitor.shared
    @AppStorage(wrappedValue: true, "EnableCloudSync", store: defaults) var enableCloudSync: Bool
    @AppStorage(wrappedValue: false, "SampleDataCreated", store: defaults) var sampleDataCreated: Bool

    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 16.0) {
                    Group {
                        if syncMonitor.syncStateSummary.isBroken {
                            Image(systemName: "xmark.icloud.fill")
                                .resizable()
                                .foregroundStyle(.red)
                        } else if syncMonitor.syncStateSummary.inProgress {
                            Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                                .resizable()
                                .foregroundStyle(.primary)
                        } else {
                            switch syncMonitor.syncStateSummary {
                            case .notStarted, .succeeded:
                                Image(systemName: "checkmark.icloud.fill")
                                    .resizable()
                                    .foregroundStyle(.green)
                            case .noNetwork:
                                Image(systemName: "bolt.horizontal.icloud.fill")
                                    .resizable()
                                    .foregroundStyle(.orange)
                            default:
                                Image(systemName: "exclamationmark.icloud.fill")
                                    .resizable()
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .symbolRenderingMode(.multicolor)
                    .scaledToFit()
                    .frame(width: 64.0, height: 64.0)
                    Group {
                        if syncMonitor.syncStateSummary.isBroken {
                            Text("More.Data.Sync.State.Error")
                        } else if syncMonitor.syncStateSummary.inProgress {
                            Text("More.Data.Sync.State.InProgress")
                        } else {
                            switch syncMonitor.syncStateSummary {
                            case .notStarted, .succeeded:
                                Text("More.Data.Sync.State.Synced")
                            case .noNetwork:
                                Text("More.Data.Sync.State.NoNetwork")
                            default:
                                Text("More.Data.Sync.State.NotSyncing")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in
                    0
                })
                Toggle(isOn: $enableCloudSync) {
                    ListRow(image: "ListIcon.CloudSync", title: "More.Data.Sync")
                }
                .disabled(true)
            } header: {
                ListSectionHeader(text: "More.Data.Sync")
                    .font(.body)
            } footer: {
                Text("More.Data.Sync.Description")
                    .font(.body)
            }
            if !sampleDataCreated {
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
        }
//        .onChange(of: enableCloudSync) { _, newValue in
//            sharedModelContainer = newContainer()
//            if !newValue {
//                let container = CKContainer(identifier: "iCloud.com.tsubuzaki.Meloan")
//                container.privateCloudDatabase.fetchAllRecordZones { zones, error in
//                    if let error = error {
//                        debugPrint(error.localizedDescription)
//                    } else if let zones = zones {
//                        let zoneIDs = zones.map { $0.zoneID }
//                        let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil,
//                                                                             recordZoneIDsToDelete: zoneIDs)
//                        deletionOperation.modifyRecordZonesResultBlock = { _ in }
//                        container.privateCloudDatabase.add(deletionOperation)
//                    }
//                }
//            }
//        }
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
        person1.id = "SAMPLE-PERSON-1"
        person2.id = "SAMPLE-PERSON-2"
        person3.id = "SAMPLE-PERSON-3"
        modelContext.insert(person1)
        modelContext.insert(person2)
        modelContext.insert(person3)
        receiptItem2.setPurchaser(to: person1)
        receiptItem3.setPurchaser(to: person2)
        receiptItem4.setPurchaser(to: person3)
        receipt.id = "SAMPLE-RECEIPT"
        receipt.addReceiptItems(from: [receiptItem1, receiptItem2, receiptItem3,
                                       receiptItem4, receiptItem5])
        receipt.addDiscountItems(from: [discountItem])
        receipt.addTaxItems(from: [taxItem1, taxItem2])
        receipt.setPersonWhoPaid(to: person1)
        receipt.addPeopleWhoParticipated(from: [person1, person2, person3])
        modelContext.insert(receipt)
        withAnimation {
            sampleDataCreated = true
        }
    }
}
