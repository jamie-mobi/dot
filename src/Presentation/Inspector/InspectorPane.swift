//
//  InspectorPane.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

enum InspectorPane: String, CaseIterable, Identifiable {
    case backlinks
    case outgoing
    case outline
    case tags

    // MARK: - Identifiable

    var id: Self {
        self
    }

    // MARK: - Display

    var title: String {
        switch self {
        case .backlinks:
            String(localized: "Backlinks")
        case .outgoing:
            String(localized: "Outgoing")
        case .outline:
            String(localized: "Outline")
        case .tags:
            String(localized: "Tags")
        }
    }

    var systemImage: String {
        switch self {
        case .backlinks:
            "arrow.down.left"
        case .outgoing:
            "arrow.up.right"
        case .outline:
            "list.bullet.indent"
        case .tags:
            "number"
        }
    }
}
