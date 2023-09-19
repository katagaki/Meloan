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

    typealias DefaultQuery = ReceiptQuery

    let id: String
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Receipt"
    static var defaultQuery: ReceiptQuery = ReceiptQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    @MainActor
    static func allReceipts() -> [Receipt] {
        if let allReceipts = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Receipt>()) {
            return allReceipts.sorted(by: { $0.name < $1.name })
        } else {
            return []
        }
    }
}

struct ReceiptQuery: EntityQuery {

    typealias Entity = ReceiptEntity

    func entities(for identifiers: [ReceiptEntity.ID]) async throws -> [ReceiptEntity] {
         await ReceiptEntity.allReceipts()
             .map({ receipt in
             ReceiptEntity(id: receipt.id, name: receipt.name)
         })
             .filter { identifiers.contains($0.id) }
     }

     func suggestedEntities() async throws -> [ReceiptEntity] {
         await ReceiptEntity.allReceipts().map({ receipt in
             ReceiptEntity(id: receipt.id, name: receipt.name)
         })
     }

     func defaultResult() async -> ReceiptEntity? {
         try? await suggestedEntities().first
     }
}
