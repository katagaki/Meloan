//
//  MoreView.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/16.
//

import Komponents
import SwiftUI

// swiftlint:disable type_body_length
struct MoreView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage(wrappedValue: true, "MarkSelfPaid", store: defaults) var markSelfPaid: Bool
    @AppStorage(wrappedValue: 0.0, "TaxRate", store: defaults) var taxRate: Double
    @AppStorage(wrappedValue: "", "TaxRateCountry", store: defaults) var taxRateCountry: String
    @AppStorage(wrappedValue: "", "TaxRateType", store: defaults) var taxRateType: String
    @AppStorage(wrappedValue: false, "AddTenPercent", store: defaults) var addTenPercent: Bool
    @AppStorage(wrappedValue: "", "CurrencySymbol", store: defaults) var currencySymbol: String
    @AppStorage(wrappedValue: true, "ShowDecimals", store: defaults) var showDecimals: Bool

    var body: some View {
        NavigationStack(path: $navigationManager.moreTabPath) {
            MoreList(repoName: "katagaki/Meloan", viewPath: ViewPath.moreAttributions) {
                Section {
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
                    Toggle(isOn: $markSelfPaid, label: {
                        ListRow(image: "ListIcon.MarkSelfPaid",
                                title: "More.Receipts.MarkSelfPaid",
                                subtitle: "More.Receipts.MarkSelfPaid.Description",
                                includeSpacer: true)
                    })
                    Menu {
                        Button {
                            taxRate = 0.0
                            taxRateCountry = ""
                            taxRateType = ""
                        } label: {
                            HStack {
                                Text("TaxRate.Disable")
                                if taxRateCountry == "" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        ForEach(Array(taxRates.keys).sorted(), id: \.self) { countryCode in
                            if let rate = taxRates[countryCode] {
                               if let states = rate.states {
                                   Menu(countryName(for: countryCode)) {
                                       ForEach(Array(states.keys).sorted(), id: \.self) { stateCode in
                                           if let state = states[stateCode] {
                                               taxRateButton(countryCode: "\(countryCode)-\(stateCode)",
                                                             rate: state)
                                           }
                                       }
                                   }
                                } else {
                                    taxRateButton(countryCode: countryCode, rate: rate)
                                }
                            }
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 8.0) {
                            ListRow(image: "ListIcon.TaxRate",
                                    title: "More.Receipts.AutomaticTaxRate",
                                    subtitle: "More.Receipts.AutomaticTaxRate.Description",
                                    includeSpacer: true)
                            .multilineTextAlignment(.leading)
                            Group {
                                if taxRateCountry == "" {
                                    Text("TaxRate.Disable")
                                } else {
                                    Text(countryName(for: taxRateCountry))
                                }
                            }
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                        .tint(.primary)
                    }
                    Toggle(isOn: $addTenPercent, label: {
                        ListRow(image: "ListIcon.ServiceCharge",
                                title: "More.Receipts.ServiceCharge",
                                subtitle: "More.Receipts.ServiceCharge.Description",
                                includeSpacer: true)
                    })
                } header: {
                    ListSectionHeader(text: "More.Receipts")
                        .font(.body)
                } footer: {
                    Text("More.Receipts.Footer")
                        .font(.subheadline)
                }
                Section {
                    Menu {
                        Button {
                            currencySymbol = ""
                        } label: {
                            HStack {
                                Text("Currency.Hide")
                                if currencySymbol == "" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        ForEach(Array(taxRates.keys).sorted(), id: \.self) { countryCode in
                            if let rate = taxRates[countryCode],
                               let currencyCode = rate.currency {
                                Button {
                                    currencySymbol = currencyCode
                                } label: {
                                    Text(NSLocalizedString("Currency.\(currencyCode)", comment: ""))
                                        .tag(currencyCode)
                                    if currencySymbol == currencyCode {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 8.0) {
                            ListRow(image: "ListIcon.CurrencySymbol",
                                    title: "More.Currency.Symbol",
                                    includeSpacer: true)
                            .multilineTextAlignment(.leading)
                            Group {
                                if currencySymbol == "" {
                                    Text("Currency.Hide")
                                } else {
                                    Text(NSLocalizedString("Currency.\(currencySymbol)", comment: ""))
                                }
                            }
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                        .tint(.primary)
                    }
                    Toggle(isOn: $showDecimals, label: {
                        ListRow(image: "ListIcon.Decimals",
                                title: "More.Currency.Decimals",
                                includeSpacer: true)
                    })
                } header: {
                    ListSectionHeader(text: "More.Currency")
                        .font(.body)
                }
                Section {
                    NavigationLink(value: ViewPath.moreTroubleshooting) {
                        ListRow(image: "ListIcon.Troubleshooting",
                                title: "More.Troubleshooting")
                    }
                } header: {
                    ListSectionHeader(text: "More.Advanced")
                        .font(.body)
                }
            }
            .navigationDestination(for: ViewPath.self) { viewPath in
                switch viewPath {
                case .moreData: MoreManageDataView()
                case .moreAppIcon: MoreAppIconView()
                case .moreTroubleshooting: MoreTroubleshootingView()
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
"""),
                    License(libraryName: "node-sales-tax", text:
"""
Copyright (c) 2017 Valerian Saliou

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
"""),
                    License(libraryName: "states_hash.json", text:
"""
This app uses data from states_hash.json. For more information, visit https://gist.github.com/mshafrir/2646763.
""")
                ])
                default: Color.clear
                }
            }
        }
        .onChange(of: currencySymbol, { _, _ in
            MeloanApp.reloadWidget()
        })
        .onChange(of: showDecimals, { _, _ in
            MeloanApp.reloadWidget()
        })
    }

    @ViewBuilder
    func taxRateButton(countryCode: String, rate: TaxRate) -> some View {
        Button {
            taxRateCountry = countryCode
            taxRate = rate.rate
            taxRateType = rate.type.rawValue
        } label: {
            HStack {
                Text(verbatim: countryName(for: countryCode))
                if countryCode == taxRateCountry {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
// swiftlint:enable type_body_length
