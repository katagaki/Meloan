//
//  IOUView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import Komponents
import SwiftData
import SwiftUI

struct IOUView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Person.name) private var people: [Person]
    @Query private var receipts: [Receipt]
    @State var personWhoPaid: Person?

    var body: some View {
        NavigationStack(path: $navigationManager.iouTabPath) {
            List {
                if let personWhoPaid = personWhoPaid, !(personWhoPaid.receiptsPaid?.isEmpty ?? true) {
                    ForEach(people) { person in
                        if person.id != personWhoPaid.id {
                            Section {
                                ForEach(receipts) { receipt in
                                    if receipt.personWhoPaid == personWhoPaid &&
                                        receipt.contains(participant: person) {
                                        IOURow(name: receipt.name,
                                               price: receipt.sumOwed(to: personWhoPaid, for: person))
                                    }
                                }
                            } header: {
                                ListSectionHeader(text: person.name)
                                    .font(.body)
                            } footer: {
                                IOURow(name: "IOU.TotalBorrowed",
                                       price: receipts.reduce(into: 0.0, { partialResult, receipt in
                                    if receipt.contains(participant: person) {
                                        partialResult += receipt.sumOwed(to: personWhoPaid, for: person)
                                    }
                                }))
                                .font(.body)
                                .bold()
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("ViewTitle.IOU")
            .safeAreaInset(edge: .bottom) {
                Picker(selection: $personWhoPaid) {
                    Text("Shared.NoSelection")
                        .tag(nil as Person?)
                    ForEach(people) { person in
                        PersonRow(person: person)
                            .tag(person as Person?)
                    }
                } label: {
                    Text("IOU.SelectLender")
                        .bold()
                }
                .pickerStyle(.navigationLink)
                .padding()
                .background(.regularMaterial)
            }
        }
    }
}
