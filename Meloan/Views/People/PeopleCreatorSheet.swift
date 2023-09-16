//
//  PeopleCreatorSheet.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import PhotosUI
import SwiftUI

struct PeopleCreatorSheet: View {

    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var selectedPhoto: Data?
    @State var selectedPhotoItem: PhotosPickerItem?
    @State var onCreate: () -> Void

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
                                    Image("Person.Generic")
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
                    TextField("People.NewPersonName", text: $name)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Shared.Cancel")
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onCreate()
                        dismiss()
                    } label: {
                        Text("Shared.Create")
                    }
                    .buttonStyle(.plain)
                    .disabled(name == "")
                }
            }
            .navigationTitle("Alert.CreateNewPerson.Title")
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
