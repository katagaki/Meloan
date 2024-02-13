//
//  PeopleView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/15.
//

import Komponents
import SwiftData
import SwiftUI
import TipKit

struct PeopleView: View {

    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Person.name) var people: [Person]

    var body: some View {
        NavigationStack(path: $navigationManager.peopleTabPath) {
            VStack(alignment: .leading, spacing: 0.0) {
                TipView(PeopleTip())
                    .padding(20.0)
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
                            modelContext.delete(people[index + 1])
                        }
                    })
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .bottom, spacing: 0.0) {
                    HStack(alignment: .center, spacing: 16.0) {
                        Spacer()
                        NavigationLink(value: ViewPath.personCreator) {
                            HStack(alignment: .center, spacing: 8.0) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18.0, height: 18.0)
                                Text("Shared.Create")
                                    .bold()
                            }
                            .padding([.leading, .trailing], 2.0)
                        }
                        .padding([.top, .bottom], 6.0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Material.bar)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .frame(height: 1/3)
                            .foregroundColor(.primary.opacity(0.2))
                    }
                }
            }
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .personCreator: PersonCreator()
                case .personEditor(let person): PersonEditor(person: person)
                default: Color.clear
                }
            })
            .navigationTitle("ViewTitle.People")
        }
    }
}
