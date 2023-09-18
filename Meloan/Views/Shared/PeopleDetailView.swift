//
//  PeopleDetailView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Komponents
import SwiftUI

struct PeopleDetailView: View {

    @Environment(\.dismiss) var dismiss
    @State var person: Person

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Group {
                        if let photo = person.photo,
                           let image = UIImage(data: photo) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image("Profile.Generic")
                                .resizable()
                        }
                    }
                    .frame(width: 144, height: 144)
                    .clipShape(Circle())
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            Section {
                HStack(alignment: .center, spacing: 16.0) {
                    ListRow(image: "ListIcon.Person.Name", title: "Person.Name")
                    Spacer()
                    Text(person.name)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
