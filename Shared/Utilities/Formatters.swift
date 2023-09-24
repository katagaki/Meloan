//
//  Formatters.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/23.
//

import Foundation

func format(_ price: Double) -> String {
    let currencySymbol = defaults.string(forKey: "CurrencySymbol") ?? ""
    if defaults.value(forKey: "ShowDecimals") == nil || defaults.bool(forKey: "ShowDecimals") {
        return String(format: "\(currencySymbol == "" ? "" : currencySymbol + " ")%.2f", price)
    } else {
        return String(format: "\(currencySymbol == "" ? "" : currencySymbol + " ")%.0f", price)
    }
}

func formatter() -> NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.generatesDecimalNumbers = true
    if defaults.value(forKey: "ShowDecimals") == nil || defaults.bool(forKey: "ShowDecimals") {
        numberFormatter.alwaysShowsDecimalSeparator = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
    } else {
        numberFormatter.maximumFractionDigits = 0
    }
    return numberFormatter
}

func countryName(for countryCode: String) -> String {
    let langCode = Locale.preferredLanguages[0]
    let current = Locale(identifier: langCode)
    if countryCode.contains("-") {
        if let stateName = stateNames[countryCode] {
            return stateName.name(language: current.language.languageCode?.identifier ?? "")
        }
        return countryCode
    } else {
        return current.localizedString(forRegionCode: countryCode) ?? countryCode
    }
}
