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
    @State var title: String
    @Binding var selection: [Person]?

    var body: some View {
        List {
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
        .navigationTitle(LocalizedStringKey(title))
    }
}
