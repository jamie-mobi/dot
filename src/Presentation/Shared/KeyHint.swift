//
//  KeyHint.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

struct KeyHint: Identifiable, Hashable {
    // MARK: - Properties

    let keys: String
    let title: String

    // MARK: - Identifiable

    var id: String {
        title
    }

    // MARK: - Common

    static let close = KeyHint(keys: "esc", title: String(localized: "Close"))
}
