//
//  ReceiptItemAssignableRow.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptItemAssignableRow: View {

    var item: ReceiptItem
    @State var name: String
    @State var price: Double
    @State var personWhoOrdered: Person?
    @Binding var peopleWhoParticipated: [Person]
    var placeholderText: String

    init(item: ReceiptItem, peopleWhoParticipated: Binding<[Person]>, placeholderText: String) {
        self.item = item
        name = item.name
        price = item.price
        personWhoOrdered = item.person
        self._peopleWhoParticipated = peopleWhoParticipated
        self.placeholderText = placeholderText
    }

    var body: some View {
        GeometryReader { metrics in
            HStack(alignment: .center, spacing: 16.0) {
                Menu {
                    Button {
                        personWhoOrdered = nil
                    } label: {
                        Image("Profile.Shared.Circle")
                        Text("Shared.Shared")
                    }
                    ForEach(peopleWhoParticipated) { person in
                        Button {
                            personWhoOrdered = person
                        } label: {
                            PersonRow(person: person)
                        }
                    }
                } label: {
                    if let personWhoOrdered = personWhoOrdered {
                        Group {
                            if let photo = personWhoOrdered.photo, let image = UIImage(data: photo) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image("Profile.Generic")
                                    .resizable()
                            }
                        }
                        .frame(width: 30.0, height: 30.0)
                        .clipShape(Circle())
                    } else {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("Profile.Shared")
                                .resizable()
                                .frame(width: 30.0, height: 30.0)
                                .clipShape(Circle())
                        }
                    }
                }
                TextField(LocalizedStringKey(placeholderText), text: $name)
                    .textInputAutocapitalization(.words)
                    .frame(minWidth: (metrics.size.width * 0.65) - 46.0)
                Divider()
                TextField("Receipt.Price", value: $price, formatter: formatter())
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .font(.system(size: 14.0))
                .monospaced()
            }
        }
        .onChange(of: name, initial: false) { _, _ in
            item.name = name
        }
        .onChange(of: price, initial: false) { _, _ in
            item.price = price
        }
        .onChange(of: personWhoOrdered, initial: false) { _, _ in
            item.person = personWhoOrdered
            MeloanApp.reloadWidget()
        }
        .onChange(of: peopleWhoParticipated, initial: false) { _, _ in
            if let personWhoOrdered = personWhoOrdered {
                if !peopleWhoParticipated.contains(personWhoOrdered) {
                    self.personWhoOrdered = nil
                }
            }
        }
    }
}
