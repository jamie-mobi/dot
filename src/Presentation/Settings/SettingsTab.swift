//
//  SettingsTab.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

enum SettingsTab: String, CaseIterable, Identifiable {
    case general
    case editor
    case filesAndLinks = "files"
    case dailyNotes = "daily"
    case appearance
    case shortcuts

    // MARK: - Identifiable

    var id: String {
        rawValue
    }

    // MARK: - Display

    var title: String {
        switch self {
        case .general:
            String(localized: "General")
        case .editor:
            String(localized: "Editor")
        case .filesAndLinks:
            String(localized: "Files & Links")
        case .dailyNotes:
            String(localized: "Daily Notes")
        case .appearance:
            String(localized: "Appearance")
        case .shortcuts:
            String(localized: "Shortcuts")
        }
    }

    var systemImage: String {
        switch self {
        case .general:
            "gearshape"
        case .editor:
            "pencil"
        case .filesAndLinks:
            "link"
        case .dailyNotes:
            "calendar"
        case .appearance:
            "circle.lefthalf.filled"
        case .shortcuts:
            "command"
        }
    }
}
