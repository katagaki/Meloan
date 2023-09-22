//
//  SettingsManager.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/22.
//

import Foundation

class SettingsManager: ObservableObject {

    let defaults = UserDefaults(suiteName: "group.com.tsubuzaki.Meloan")!

    @Published var currencySymbol: String = ""
    @Published var showDecimals: Bool = true
    @Published var markSelfPaid: Bool = true

    init() {
        // Set default settings
        if defaults.value(forKey: "CurrencySymbol") == nil {
            defaults.set("", forKey: "CurrencySymbol")
        }
        if defaults.value(forKey: "ShowDecimals") == nil {
            defaults.set(true, forKey: "ShowDecimals")
        }
        if defaults.value(forKey: "MarkSelfPaid") == nil {
            defaults.set(true, forKey: "MarkSelfPaid")
        }

        // Load configuration into global variables
        currencySymbol = defaults.string(forKey: "CurrencySymbol") ?? ""
        showDecimals = defaults.bool(forKey: "ShowDecimals")
        markSelfPaid = defaults.bool(forKey: "MarkSelfPaid")
    }

    func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func setCurrencySymbol(_ newValue: String) {
        defaults.set(newValue, forKey: "CurrencySymbol")
        currencySymbol = newValue
    }

    func setShowDecimals(_ newValue: Bool) {
        defaults.set(newValue, forKey: "ShowDecimals")
        showDecimals = newValue
    }

    func setMarkSelfPaid(_ newValue: Bool) {
        defaults.set(newValue, forKey: "MarkSelfPaid")
        markSelfPaid = newValue
    }

    func format(_ price: Double) -> String {
        if showDecimals {
            return String(format: "\(currencySymbol == "" ? "" : currencySymbol + " ")%.2f", price)
        } else {
            return String(format: "\(currencySymbol == "" ? "" : currencySymbol + " ")%.0f", price)
        }
    }

    func formatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.generatesDecimalNumbers = true
        if showDecimals {
            numberFormatter.alwaysShowsDecimalSeparator = true
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
        } else {
            numberFormatter.maximumFractionDigits = 0
        }
        if currencySymbol != "" {
            numberFormatter.numberStyle = .currency
            numberFormatter.currencyCode = currencySymbol
            numberFormatter.currencySymbol = currencySymbol
        }
        return numberFormatter
    }
}
