//
//  PeoplePicker.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import Komponents
import SwiftData
import SwiftUI
import UIKit

struct PeoplePicker: View {

    @Environment(\.dismiss) var dismiss
    @Query(sort: \Person.name) var people: [Person]
    var title: String
    @Binding var selection: [Person]?
    @State private var isAddingPerson: Bool = false

    var body: some View {
        List {
            if people.filter({ $0.id != "ME" }).isEmpty {
                Text("PeoplePicker.Empty")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
            if let mePerson = people.first(where: { $0.id == "ME" }) {
                Button {
                    if selection?.contains(where: { $0.id == "ME" }) ?? false {
                        selection?.removeAll { selectedPerson in
                            selectedPerson.id == "ME"
                        }
                    } else {
                        selection?.append(mePerson)
                    }
                } label: {
                    HStack {
                        PersonRow(person: mePerson)
                            .tint(.primary)
                        Spacer()
                        if selection?.contains(where: { $0.id == "ME" }) ?? false {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .opacity(0)
                        }
                    }
                }
            }
            ForEach(people.filter({ $0.id != "ME" })) { person in
                Button {
                    if selection?.contains(where: { $0.id == person.id }) ?? false {
                        selection?.removeAll { selectedPerson in
                            selectedPerson.id == person.id
                        }
                    } else {
                        selection?.append(person)
                    }
                } label: {
                    HStack {
                        PersonRow(person: person)
                            .tint(.primary)
                        Spacer()
                        if selection?.contains(where: { $0.id == person.id }) ?? false {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .opacity(0)
                        }
                    }
                }
            }
            Button {
                isAddingPerson = true
            } label: {
                Label("PeoplePicker.AddPerson", systemImage: "person.badge.plus")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Shared.Done")
                }
            }
        }
        .sheet(isPresented: $isAddingPerson) {
            NavigationStack {
                PersonCreator()
            }
        }
        .navigationTitle(LocalizedStringKey(title))
    }
}
