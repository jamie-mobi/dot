//
//  SearchLineKind+Title.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore

extension SearchLineKind {
    var title: String {
        switch self {
        case .text:
            String(localized: "Text")
        case .quote:
            String(localized: "Quote")
        case .property:
            String(localized: "Property")
        }
    }
}
