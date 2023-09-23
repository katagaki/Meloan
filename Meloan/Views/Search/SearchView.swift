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
    @Query var receipts: [Receipt]
    @Query var receiptItems: [ReceiptItem]
    @Query var people: [Person]

    @AppStorage(wrappedValue: [], "SearchHistory", store: defaults) var searchHistory: [String]
    @State var searchTerm: String = ""

    var body: some View {
        NavigationStack(path: $navigationManager.searchTabPath) {
            List {
                if searchTermTrimmed() == "" {
                    Section {
                        ForEach(searchHistory, id: \.self) { historicalSearchTerm in
                            Button {
                                withAnimation {
                                    searchTerm = historicalSearchTerm
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 16.0) {
                                    Image(systemName: "magnifyingglass")
                                    Text(historicalSearchTerm)
                                    Spacer()
                                    Image(systemName: "arrow.up.backward.circle")
                                        .symbolRenderingMode(.hierarchical)
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
                                NavigationLink(value: ViewPath.receiptDetail(receipt: receipt)) {
                                    ListRow(image: "ListIcon.Receipt",
                                            title: receipt.name,
                                            subtitle: format(receipt.sum()))
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
                                NavigationLink(value: ViewPath.receiptItemDetail(receiptItem: receiptItem)) {
                                    ListRow(image: "ListIcon.ReceiptItem",
                                            title: receiptItem.name,
                                            subtitle: format(receiptItem.price))
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
                                NavigationLink(value: ViewPath.personDetail(person: person)) {
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
                            }
                        } header: {
                            ListSectionHeader(text: "Search.People")
                                .font(.body)
                        }
                    }
                }
            }
            .navigationDestination(for: ViewPath.self, destination: { viewPath in
                switch viewPath {
                case .receiptDetail(let receipt): ReceiptDetailView(receipt: receipt)
                case .receiptItemDetail(let receiptItem): ReceiptItemDetailView(receiptItem: receiptItem)
                case .personDetail(let person): PeopleDetailView(person: person)
                default: Color.clear
                }
            })
            .searchable(text: $searchTerm)
            .onSubmit(of: .search, {
                if searchHistory.contains(where: { $0 == searchTerm }) {
                    searchHistory.removeAll(where: { $0 == searchTerm })
                }
                searchHistory.insert(searchTerm, at: 0)
            })
            .onChange(of: navigationManager.searchTabPath, { oldValue, newValue in
                if oldValue.count == 0 && newValue.count == 1 {
                    if searchHistory.contains(searchTerm) {
                        searchHistory.removeAll(where: { $0 == searchTerm })
                    }
                    searchHistory.insert(searchTerm, at: 0)
                }
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
