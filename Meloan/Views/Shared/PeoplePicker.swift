//
//  PeoplePicker.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import SwiftData
import SwiftUI

struct PeoplePicker: View {

    @Query private var people: [Person]
    @State var title: String
    @Binding var selection: [Person]

    var body: some View {
        List {
            if let mePerson = people.first(where: { $0.id == "ME" }) {
                PersonRow(person: mePerson)
            }
            ForEach(people.filter({ $0.id != "ME" })) { person in
                Button {
                    if selection.contains(where: { $0.id == person.id }) {
                        selection.removeAll { selectedPerson in
                            selectedPerson.id == person.id
                        }
                    } else {
                        selection.append(person)
                    }
                } label: {
                    HStack {
                        PersonRow(person: person)
                            .tint(.white)
                        Spacer()
                        if selection.contains(where: { $0.id == person.id }) {
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
        .navigationTitle(LocalizedStringKey(title))
    }
}
