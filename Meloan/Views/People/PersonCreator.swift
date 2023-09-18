//
//  PersonCreator.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import PhotosUI
import SwiftUI

struct PersonCreator: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var selectedPhoto: Data?
    @State var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Shared.Cancel")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let newPerson = Person(name: name, photo: selectedPhoto)
                        modelContext.insert(newPerson)
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        Text("Shared.Create")
                    }
                    .disabled(name == "")
                }
            }
            .navigationTitle("People.Create.Title")
            .navigationBarTitleDisplayMode(.inline)
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
