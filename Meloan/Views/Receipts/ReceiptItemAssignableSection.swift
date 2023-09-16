//
//  ReceiptItemAssignableSection.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptItemAssignableSection: View {

    @Query private var people: [Person]
    @State var name: String
    @State var price: Double
    @Binding var personWhoOrdered: Person?

    var body: some View {
        Section {
            HStack(alignment: .center, spacing: 16.0) {
                Text("Receipt.OrderedBy")
                Divider()
                Menu {
                    Button {
                        personWhoOrdered = nil
                    } label: {
                        Text("Shared.Shared")
                    }
                    ForEach(people) { person in
                        Button {
                            personWhoOrdered = person
                        } label: {
                            PersonRow(person: person)
                        }
                    }
                } label: {
                    if let personWhoOrdered = personWhoOrdered {
                        PersonRow(person: personWhoOrdered)
                    } else {
                        Text("Shared.Shared")
                    }
                    Spacer()
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        } header: {
            HStack(alignment: .top, spacing: 4.0) {
                Text(LocalizedStringKey(name))
                Spacer()
                Text(price, format: .currency(code: "SGD"))
            }
            .font(.system(size: 14.0))
            .monospaced()
            .textCase(.none)
            .foregroundStyle(.primary)
        }
    }
}
