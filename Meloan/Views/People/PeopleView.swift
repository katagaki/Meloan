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
                    PersonRow(person: person)
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        modelContext.delete(people[index])
                    }
                })
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        EditButton()
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
            }
            .sheet(isPresented: $isCreatingPerson, content: {
                PersonCreator(name: $newPersonName,
                              selectedPhoto: $newPersonPhoto,
                              onCreate: {
                    let newPerson = Person(name: newPersonName, photo: newPersonPhoto)
                    modelContext.insert(newPerson)
                    try? modelContext.save()
                })
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
            })
            .navigationTitle("ViewTitle.People")
        }
    }
}
