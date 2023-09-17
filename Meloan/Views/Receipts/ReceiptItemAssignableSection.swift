//
//  ReceiptItemAssignableSection.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import SwiftData
import SwiftUI

struct ReceiptItemAssignableSection: View {

    @State var name: String
    @State var price: Double
    @Binding var personWhoOrdered: Person?
    @Binding var peopleWhoParticipated: [Person]

    var body: some View {
        Section {
            HStack(alignment: .center, spacing: 16.0) {
                Text("Receipt.OrderedBy")
                Divider()
                Menu {
                    Button {
                        personWhoOrdered = nil
                    } label: {
                        Image("Profile.Shared")
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
                        PersonRow(person: personWhoOrdered)
                    } else {
                        HStack(alignment: .center, spacing: 16.0) {
                            Image("Profile.Shared")
                                .resizable()
                            .frame(width: 30.0, height: 30.0)
                            .clipShape(Circle())
                            Text("Shared.Shared")
                                .font(.body)
                        }
                    }
                    Spacer()
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        } header: {
            HStack(alignment: .top, spacing: 4.0) {
                Text(LocalizedStringKey(name))
                Spacer()
                Text("\(price, specifier: "%.2f")")
            }
            .font(.system(size: 14.0))
            .monospaced()
            .textCase(.none)
            .foregroundStyle(.primary)
        }
    }
}
