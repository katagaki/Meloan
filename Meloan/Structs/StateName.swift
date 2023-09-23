//
//  StateName.swift
//  Meloan
//
//  Created by シン・ジャスティン on 2023/09/23.
//

import Foundation

struct StateName: Codable {
    // swiftlint: disable identifier_name
    var en: String
    var ja: String
    // swiftlint: enable identifier_name

    typealias List = [String: StateName]

    func name(language: String) -> String {
        switch language {
        case "en": return en
        case "ja": return ja
        default: return en
        }
    }
}
