//
//  MoreView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftUI

struct MoreView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        NavigationStack(path: $navigationManager.moreTabPath) {
            MoreList(repoName: "katagaki/Meloan", viewPath: ViewPath.moreAttributions) {
                // TODO: Add setting options for default tax rate, currency, etc
                Section {
                    Toggle(isOn: $settings.markSelfPaid, label: {
                        ListRow(image: "ListIcon.MarkSelfPaid",
                                title: "More.MarkSelfPaid",
                                includeSpacer: true)
                    })
                    NavigationLink(value: ViewPath.moreData) {
                        ListRow(image: "ListIcon.DataManagement",
                                title: "More.Data")
                    }
                } header: {
                    ListSectionHeader(text: "More.General")
                        .font(.body)
                }
                Section {
                    NavigationLink(value: ViewPath.moreAppIcon) {
                        ListRow(image: "ListIcon.AppIcon",
                                title: "More.Customization.AppIcon")
                    }
                } header: {
                    ListSectionHeader(text: "More.Customization")
                        .font(.body)
                }
                Section {
                    Picker(selection: $settings.currencySymbol) {
                        Text("Currency.Hide")
                            .tag("")
                        Text("Currency.JPY")
                            .tag("JPY")
                        Text("Currency.SGD")
                            .tag("SGD")
                        Text("Currency.USD")
                            .tag("USD")
                        Text("Currency.VND")
                            .tag("VND")
                    } label: {
                        ListRow(image: "ListIcon.CurrencySymbol",
                                title: "More.Currency.Symbol")
                    }
                    Toggle(isOn: $settings.showDecimals, label: {
                        ListRow(image: "ListIcon.Decimals",
                                title: "More.Currency.Decimals",
                                includeSpacer: true)
                    })
                } header: {
                    ListSectionHeader(text: "More.Currency")
                        .font(.body)
                }
            }
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .moreData: ManageDataView()
                case .moreAppIcon: MoreAppIconView()
                case .moreAttributions: LicensesView(licenses: [
                    License(libraryName: "ConfettiSwiftUI", text:
"""
MIT License

Copyright (c) 2020 Simon Bachmann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""")
                ])
                default: Color.clear
                }
            }
        }
        .onChange(of: settings.currencySymbol, { _, newValue in
            settings.setCurrencySymbol(newValue)
            MeloanApp.reloadWidget()
        })
        .onChange(of: settings.showDecimals, { _, newValue in
            settings.setShowDecimals(newValue)
            MeloanApp.reloadWidget()
        })
    }
}
