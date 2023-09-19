//
//  ReceiptEntity.swift
//  AssistantExtension
//
//  Created by シン・ジャスティン on 2023/09/19.
//

import AppIntents
import Foundation
import SwiftData

struct ReceiptEntity: AppEntity {

    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Receipt.self, Person.self, ReceiptItem.self, DiscountItem.self, TaxItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    let id: String
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Receipt"
    static var defaultQuery: ReceiptQuery = ReceiptQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    @MainActor
    static let allReceipts: [ReceiptEntity] = getAllReceipts().map({ receipt in
        ReceiptEntity(id: receipt.id, name: receipt.name)
    })

    @MainActor
    static func getAllReceipts() -> [Receipt] {
        if let allReceipts = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Receipt>()) {
            return allReceipts
        } else {
            return []
        }
    }
}

struct ReceiptQuery: EntityQuery {
    func entities(for identifiers: [ReceiptEntity.ID]) async throws -> [ReceiptEntity] {
        ReceiptEntity.allReceipts.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ReceiptEntity] {
        ReceiptEntity.allReceipts
    }

    func defaultResult() async -> ReceiptEntity? {
        try? await suggestedEntities().first
    }
}
