//
//  SearchView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/18.
//

import Komponents
import SwiftData
import SwiftUI

struct SearchView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @Query private var receipts: [Receipt]
    @Query private var receiptItems: [ReceiptItem]
    @Query private var people: [Person]

    let defaults = UserDefaults.standard

    @State var searchHistory: [String] = []
    @State var searchTerm: String = ""

    var body: some View {
        NavigationStack(path: $navigationManager.searchTabPath) {
            List {
                if searchTermTrimmed() == "" {
                    Section {
                        ForEach(searchHistory, id: \.self) { historicalSearchTerm in
                            Button {
                                searchTerm = historicalSearchTerm
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image(systemName: "arrow.up.backward.circle")
                                        .symbolRenderingMode(.hierarchical)
                                    Text(historicalSearchTerm)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            searchHistory.remove(atOffsets: indexSet)
                        }
                    } header: {
                        ListSectionHeader(text: "Search.History")
                            .font(.body)
                    }
                } else {
                    if !receiptsFound().isEmpty {
                        Section {
                            ForEach(receiptsFound()) { receipt in
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image("Receipt")
                                        .resizable()
                                        .frame(width: 30.0, height: 30.0)
                                    VStack(alignment: .leading, spacing: 2.0) {
                                        Text(receipt.name)
                                            .font(.body)
                                        Text("\(receipt.sum(), specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } header: {
                            ListSectionHeader(text: "Search.Receipts")
                                .font(.body)
                        }
                    }
                    if !receiptItemsFound().isEmpty {
                        Section {
                            ForEach(receiptItemsFound()) { receiptItem in
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image("Receipt.Item")
                                        .resizable()
                                        .frame(width: 30.0, height: 30.0)
                                    VStack(alignment: .leading, spacing: 2.0) {
                                        Text(receiptItem.name)
                                            .font(.body)
                                        Text("\(receiptItem.price, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } header: {
                            ListSectionHeader(text: "Search.ReceiptItems")
                                .font(.body)
                        }
                    }
                    if !peopleFound().isEmpty {
                        Section {
                            ForEach(peopleFound()) { person in
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
                                    Text(person.name)
                                        .font(.body)
                                }
                            }
                        } header: {
                            ListSectionHeader(text: "Search.People")
                                .font(.body)
                        }
                    }
                }
            }
            .searchable(text: $searchTerm)
            .onSubmit(of: .search, {
                if searchHistory.contains(where: { $0 == searchTerm }) {
                    searchHistory.removeAll(where: { $0 == searchTerm })
                }
                searchHistory.insert(searchTerm, at: 0)
            })
            .onAppear {
                if let storedSearchHistory = defaults.array(forKey: "SearchHistory") as? [String] {
                    searchHistory = storedSearchHistory
                }
            }
            .onChange(of: searchHistory, { _, newValue in
                defaults.setValue(newValue, forKey: "SearchHistory")
            })
            .navigationTitle("ViewTitle.Search")
        }
    }

    func searchTermTrimmed() -> String {
        return searchTerm.trimmingCharacters(in: .whitespaces)
    }

    func receiptsFound() -> [Receipt] {
        return receipts
            .filter({ $0.name.lowercased().contains(searchTermTrimmed().lowercased())})
            .sorted { lhs, rhs in
                lhs.name < rhs.name
            }
    }

    func receiptItemsFound() -> [ReceiptItem] {
        return receiptItems
            .filter({ $0.name.lowercased().contains(searchTermTrimmed().lowercased())})
            .sorted { lhs, rhs in
                lhs.name < rhs.name
            }
    }

    func peopleFound() -> [Person] {
        return people
            .filter({ $0.id != "ME" && $0.name.lowercased().contains(searchTermTrimmed().lowercased())})
            .sorted { lhs, rhs in
                lhs.name < rhs.name
            }
    }
}
