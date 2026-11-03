//
//  HomeLayout.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

enum HomeLayout: String, CaseIterable, Identifiable {
    case cards
    case list

    // MARK: - Identifiable

    var id: String {
        rawValue
    }

    // MARK: - Display

    var title: String {
        switch self {
        case .cards:
            String(localized: "Cards")
        case .list:
            String(localized: "List")
        }
    }

    var systemImage: String {
        switch self {
        case .cards:
            "square.grid.2x2"
        case .list:
            "list.bullet"
        }
    }
}
