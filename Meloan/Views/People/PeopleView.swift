//
//  PeopleView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import Komponents
import SwiftData
import SwiftUI

struct PeopleView: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Person.name) var people: [Person]

    var body: some View {
        NavigationStack(path: $navigationManager.peopleTabPath) {
            List {
                if let mePerson = people.first(where: { $0.id == "ME" }) {
                    PersonRow(person: mePerson)
                }
                ForEach(people.filter({ $0.id != "ME" })) { person in
                    NavigationLink(value: ViewPath.personEditor(person: person)) {
                        PersonRow(person: person)
                    }
                    .deleteDisabled(!(person.receiptsPaid?.isEmpty ?? true) ||
                                    !(person.receiptsParticipated?.isEmpty ?? true))
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        modelContext.delete(people[index])
                    }
                })
            }
            .listStyle(.plain)
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .personCreator: PersonCreator()
                case .personEditor(let person): PersonEditor(person: person)
                default: Color.clear
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: ViewPath.personCreator) {
                        Image(systemName: "plus")
                    }
                    .popoverTip(PeopleTip(), arrowEdge: .top)
                }
            }
            .navigationTitle("ViewTitle.People")
        }
    }
}
