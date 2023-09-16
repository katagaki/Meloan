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
    @Query private var people: [Person]
    @State var isCreatingPerson: Bool = false
    @State var newPersonPhoto: Data?
    @State var newPersonName: String = ""

    var body: some View {
        NavigationStack(path: $navigationManager.peopleTabPath) {
            List {
                ForEach(people) { person in
                    HStack(alignment: .center, spacing: 16.0) {
                        Group {
                            if let photo = person.photo, let image = UIImage(data: photo) {
                                Image(uiImage: image)
                                    .resizable()
                            } else {
                                Image("Person.Generic")
                                    .resizable()
                            }
                        }
                        .frame(width: 30.0, height: 30.0)
                        .clipShape(Circle())
                        Text(verbatim: person.name)
                            .font(.body)
                    }
                }
                .onDelete(perform: { indexSet in
                    withAnimation {
                        for index in indexSet {
                            modelContext.delete(people[index])
                        }
                    }
                })
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatingPerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    EditButton()
                }
            }
            .sheet(isPresented: $isCreatingPerson, content: {
                PeopleCreatorSheet(name: $newPersonName, selectedPhoto: $newPersonPhoto, onCreate: {
                    withAnimation {
                        let newPerson = Person(name: newPersonName, photo: newPersonPhoto)
                        modelContext.insert(newPerson)
                    }
                })
                .presentationDetents([.medium])
            })
            .navigationTitle("ViewTitle.People")
        }
    }
}
