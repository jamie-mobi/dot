//
//  SearchScope+Title.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore

extension SearchScope {
    var title: String {
        switch self {
        case .all:
            String(localized: "Anywhere")
        case .text:
            String(localized: "Text Only")
        case .properties:
            String(localized: "Properties Only")
        }
    }
}
