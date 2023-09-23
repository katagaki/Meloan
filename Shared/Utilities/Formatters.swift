//
//  Formatters.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/23.
//

import Foundation

let defaults = UserDefaults(suiteName: "group.com.tsubuzaki.Meloan")!

func format(_ price: Double) -> String {
    let currencySymbol = defaults.string(forKey: "CurrencySymbol") ?? ""
    if defaults.bool(forKey: "ShowDecimals") {
        return String(format: "\(currencySymbol == "" ? "" : currencySymbol + " ")%.2f", price)
    } else {
        return String(format: "\(currencySymbol == "" ? "" : currencySymbol + " ")%.0f", price)
    }
}

func formatter() -> NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.generatesDecimalNumbers = true
    if defaults.bool(forKey: "ShowDecimals") {
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
    } else {
        numberFormatter.maximumFractionDigits = 0
    }
    return numberFormatter
}
