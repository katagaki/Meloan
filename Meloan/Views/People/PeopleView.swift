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

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Person.name) private var people: [Person]

    // Person Creator
    @State var isCreatingPerson: Bool = false
    @State var newPersonPhoto: Data?
    @State var newPersonName: String = ""

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
                case .personEditor(let person): PersonEditor(person: person)
                default: Color.clear
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newPersonPhoto = nil
                        newPersonName = ""
                        isCreatingPerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popoverTip(PeopleTip(), arrowEdge: .top)
                }
            }
            .sheet(isPresented: $isCreatingPerson, content: {
                PersonCreator()
                #if os(iOS)
                .presentationDetents([.medium])
                #endif
                .interactiveDismissDisabled()
            })
            .navigationTitle("ViewTitle.People")
        }
    }
}
