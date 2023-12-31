//
//  ModelContainer.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/21.
//

import Foundation
import SwiftData

var sharedModelContainer: ModelContainer = {
    newContainer()
}()

func isCloudSyncEnabled() -> Bool {
    return true // TODO: Wait for SwiftData implementation to toggle iCloud syncing
}

func newContainer() -> ModelContainer {
    let schema = Schema([
        Receipt.self, Person.self, ReceiptItem.self, DiscountItem.self, TaxItem.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema,
                                                isStoredInMemoryOnly: false,
                                                cloudKitDatabase: isCloudSyncEnabled() ? .automatic : .none)
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
