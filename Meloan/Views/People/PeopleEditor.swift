//
//  PeopleEditor.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Komponents
import PhotosUI
import SwiftUI

struct PersonEditor: View {

    @Environment(\.dismiss) var dismiss
    @State var person: Person
    @State var name: String = ""
    @State var selectedPhoto: Data?
    @State var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem,
                                 matching: .images,
                                 photoLibrary: .shared()) {
                        Group {
                            if let selectedPhoto = selectedPhoto,
                               let image = UIImage(data: selectedPhoto) {
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
                    }
                                 .buttonStyle(.plain)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            Section {
                TextField("Person.Name", text: $name)
            }
        }
        .navigationTitle("People.Edit.Title")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .center, spacing: 0.0) {
                Button {
                    person.name = name
                    person.photo = selectedPhoto
                    dismiss()
                } label: {
                    LargeButtonLabel(iconName: "square.and.arrow.down.fill", text: "Shared.Save")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .frame(minHeight: 56.0)
                .padding([.leading, .trailing, .bottom], 16.0)
            }
        }

        .onAppear {
            name = person.name
            selectedPhoto = person.photo
        }
        .onChange(of: selectedPhotoItem) { _, _ in
            Task {
                if let selectedPhotoItem = selectedPhotoItem,
                    let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    selectedPhoto = data
                }
            }
        }
    }
}
