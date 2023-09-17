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
    @Query private var people: [Person]
    @Query private var receipts: [Receipt]
    @State var personWhoPaid: Person?

    var body: some View {
        NavigationStack(path: $navigationManager.iouTabPath) {
            List(people) { person in
                if let personWhoPaid = personWhoPaid {
                    let amountPayable = receipts.reduce(into: 0.0) { partialResult, receipt in
                        if let personWhoPaidReceipt = receipt.personWhoPaid,
                           personWhoPaidReceipt.id == personWhoPaid.id {
                            partialResult += receipt.sumOwed(for: person)
                        }
                    }
                    if !amountPayable.isZero {
                        Section {
                            ForEach(receipts) { receipt in
                                if let personWhoPaidReceipt = receipt.personWhoPaid,
                                   personWhoPaidReceipt.id == personWhoPaid.id {
                                    IOURow(name: receipt.name, price: receipt.sumOwed(for: person))
                                }
                            }
                        } header: {
                            ListSectionHeader(text: person.name)
                                .font(.body)
                        } footer: {
                            IOURow(name: "IOU.TotalBorrowed", price: amountPayable)
                                .font(.body)
                                .bold()
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("ViewTitle.IOU")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker(selection: $personWhoPaid) {
                        Text("Shared.NoSelection")
                            .tag(nil as Person?)
                        ForEach(people) { person in
                            PersonRow(person: person)
                                .tag(person as Person?)
                        }
                    } label: {
                        Text("IOU.SelectLender")
                            .bold()
                    }
                    .pickerStyle(.navigationLink)
                }
            }
        }
    }
}
