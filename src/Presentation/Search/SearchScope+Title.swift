//
//  SearchScope+Title.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore

extension SearchScope {
    var title: String {
        switch self {
        case .all:
            String(localized: "Text and Properties")
        case .text:
            String(localized: "Text Only")
        case .properties:
            String(localized: "Properties Only")
        }
    }
}
