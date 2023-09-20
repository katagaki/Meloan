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
    var id: String
    var name: String

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Receipt")
    static var defaultQuery = ReceiptQuery()

    var displayRepresentation: DisplayRepresentation {
        // Do NOT use any other initializers! Widget settings page will stop working!
        // DisplayRepresentation(title: "\(name)") will NOT work.
        DisplayRepresentation(stringLiteral: name)
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init(from receipt: Receipt) {
        self.id = receipt.id
        self.name = receipt.name
    }
}

struct ReceiptQuery: EntityQuery, Sendable {
    func entities(for identifiers: [ReceiptEntity.ID]) async throws -> [ReceiptEntity] {
        debugPrint(#function)
        return await all().filter { identifiers.contains($0.id) }
     }

     func suggestedEntities() async throws -> [ReceiptEntity] {
         return await all()
     }

     func defaultResult() async -> ReceiptEntity? {
         debugPrint(#function)
         return try? await suggestedEntities().first
     }

    @MainActor
    func all() -> [ReceiptEntity] {
        let sharedModelContainer: ModelContainer = {
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
        do {
            let allReceipts = try sharedModelContainer
                .mainContext.fetch(FetchDescriptor<Receipt>())
                .sorted(by: { $0.name < $1.name })
                .map({ receipt in
                    ReceiptEntity(from: receipt)
                })
            for receipt in allReceipts {
                debugPrint(receipt)
            }
            return allReceipts
        } catch {
            debugPrint(error.localizedDescription)
        }
        return []
    }
}
