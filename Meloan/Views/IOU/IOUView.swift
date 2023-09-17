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
    @State var viewSafeIOUs: [IOUViewSafe] = []
    @State var personWhoPaid: Person?

    var body: some View {
        NavigationStack(path: $navigationManager.iouTabPath) {
            List(people) { person in
                if let personWhoPaid = self.personWhoPaid, !(personWhoPaid.receiptsPaid?.isEmpty ?? true) {
                    if person.id != personWhoPaid.id && person.sumOwed(to: personWhoPaid) != .zero {
                        Section {
                            ForEach(person.receiptsParticipated ?? []) { receipt in
                                if receipt.personWhoPaid == personWhoPaid {
                                    // IMPORTANT: Do NOT refactor! SwiftUI will reuse views in an unexpected
                                    // manner, and cause totals to appear incorrectly (calculation is CORRECT).
                                    HStack(alignment: .center, spacing: 4.0) {
                                        Text(receipt.name)
                                        Spacer()
                                        Text("\(receipt.sumOwed(to: personWhoPaid, for: person), specifier: "%.2f")")
                                    }
                                }
                            }
                        } header: {
                            ListSectionHeader(text: person.name)
                                .font(.body)
                        } footer: {
                            // IMPORTANT: Do NOT refactor! SwiftUI will reuse views in an unexpected
                            // manner, and cause totals to appear incorrectly (calculation is CORRECT).
                            HStack(alignment: .center, spacing: 4.0) {
                                Text("IOU.TotalBorrowed")
                                Spacer()
                                Text("\(person.sumOwed(to: personWhoPaid), specifier: "%.2f")")
                            }
                            .font(.body)
                            .bold()
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("ViewTitle.IOU")
            .overlay {
                if personWhoPaid == nil {
                    HintOverlay(image: "filemenu.and.selection", text: "IOU.Hint")
                }
            }
            .safeAreaInset(edge: .bottom) {
                Picker(selection: $personWhoPaid) {
                    Text("Shared.NoSelection")
                        .tag(nil as Person?)
                    if let mePerson = people.first(where: { $0.id == "ME" }) {
                        PersonRow(person: mePerson)
                            .tag(mePerson as Person?)
                    }
                    ForEach(people.filter({ $0.id != "ME" })) { person in
                        PersonRow(person: person)
                            .tag(person as Person?)
                    }
                } label: {
                    Text("IOU.SelectLender")
                        .bold()
                }
                .pickerStyle(.navigationLink)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
}
