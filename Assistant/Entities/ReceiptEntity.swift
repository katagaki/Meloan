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

    typealias DefaultQuery = ReceiptQuery

    let id: String
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Receipt"
    static var defaultQuery: ReceiptQuery = ReceiptQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ReceiptQuery: EntityQuery {

    typealias Entity = ReceiptEntity

    var sharedModelContainer: ModelContainer = {
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

    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
        let allReceipts = await allReceipts()
            .map({ receipt in
                ReceiptEntity(id: receipt.id, name: receipt.name)
            })
            .filter { identifiers.contains($0.id) }
        for receipt in allReceipts {
            debugPrint(#function + " \(receipt.id): \(receipt.name)")
        }
        return allReceipts
    }

    func suggestedEntities() async throws -> [Entity] {
        let allReceipts = await allReceipts()
            .map({ receipt in
                ReceiptEntity(id: receipt.id, name: receipt.name)
            })
        for receipt in allReceipts {
            debugPrint(#function + " \(receipt.id): \(receipt.name)")
        }
        return allReceipts
    }

    func defaultResult() async -> Entity? {
        return try? await suggestedEntities().first
    }

    func allReceipts() async -> [Receipt] {
        await MainActor.run {
            do {
                let allReceipts = try sharedModelContainer
                    .mainContext.fetch(FetchDescriptor<Receipt>())
                return allReceipts.sorted(by: { $0.name < $1.name })
            } catch {
                debugPrint(error.localizedDescription)
            }
            return []
        }
    }
}
