//
//  IOUView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/17.
//

import Komponents
import SwiftData
import SwiftUI

struct IOUView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @Query(sort: \Person.name) private var people: [Person]
    @Query private var receipts: [Receipt]
    @State var viewSafeIOUs: [IOUViewSafe] = []
    @State var personWhoPaid: Person?
    @State var isInitialLoadCompleted: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.iouTabPath) {
            List(people) { person in
                if let personWhoPaid = self.personWhoPaid, !(personWhoPaid.receiptsPaid?.isEmpty ?? true) {
                    if person.id != personWhoPaid.id && person.sumOwed(to: personWhoPaid) != .zero {
                        Section {
                            // IMPORTANT: Do NOT refactor anything here! SwiftUI will reuse views in an unexpected
                            // manner, and cause totals to appear incorrectly (calculation is CORRECT).
                            ForEach(person.receiptsParticipated ?? []) { receipt in
                                if receipt.personWhoPaid == personWhoPaid {
                                    HStack(alignment: .center, spacing: 4.0) {
                                        Text(receipt.name)
                                        Spacer()
                                        Text("\(receipt.sumOwed(to: personWhoPaid, for: person), specifier: "%.2f")")
                                    }
                                }
                            }
                        } header: {
                            HStack(alignment: .center, spacing: 16.0) {
                                Group {
                                    if let photo = person.photo, let image = UIImage(data: photo) {
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
                                Text(verbatim: person.name)
                                    .bold()
                                    .foregroundColor(.primary)
                                    .textCase(nil)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .allowsTightening(true)
                                    .font(.body)
                            }
                            .listRowInsets(EdgeInsets(top: 16.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
                        } footer: {
                            HStack(alignment: .center, spacing: 8.0) {
                                Text("IOU.TotalBorrowed")
                                Spacer()
                                Text("\(person.sumOwed(to: personWhoPaid), specifier: "%.2f")")
                            }
                            .font(.body)
                            .bold()
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .overlay {
                if personWhoPaid == nil {
                    HintOverlay(image: "filemenu.and.selection", text: "IOU.Hint")
                }
            }
            .safeAreaInset(edge: .bottom) {
                Picker(selection: $personWhoPaid) {
                    Text("Shared.NoSelection")
                        .tag(nil as Person?)
                    if let mePerson = people.first(where: { $0.id == "ME" }) {
                        PersonRow(person: mePerson)
                            .tag(mePerson as Person?)
                    }
                    ForEach(people.filter({ $0.id != "ME" })) { person in
                        PersonRow(person: person)
                            .tag(person as Person?)
                    }
                } label: {
                    Text("IOU.SelectLender")
                        .bold()
                }
                .pickerStyle(.navigationLink)
                .padding()
                .background(.ultraThinMaterial)
                .overlay(Rectangle().frame(width: nil,
                                            height: 1/3,
                                            alignment: .top).foregroundColor(.primary.opacity(0.3)),
                         alignment: .top)
            }
            .navigationTitle("ViewTitle.IOU")
            .onAppear {
                if !isInitialLoadCompleted {
                    personWhoPaid = people.first(where: { $0.id == "ME" })
                    isInitialLoadCompleted = true
                }
            }
        }
    }
}
