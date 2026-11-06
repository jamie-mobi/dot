//
//  AppearanceChoice.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit

enum AppearanceChoice: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    // MARK: - Identifiable

    var id: String {
        rawValue
    }

    // MARK: - Display

    var title: String {
        switch self {
        case .system:
            String(localized: "System")
        case .light:
            String(localized: "Light")
        case .dark:
            String(localized: "Dark")
        }
    }

    var systemImage: String {
        switch self {
        case .system:
            "circle.lefthalf.filled"
        case .light:
            "sun.max"
        case .dark:
            "moon"
        }
    }

    var appearance: NSAppearance? {
        switch self {
        case .system:
            nil
        case .light:
            NSAppearance(named: .aqua)
        case .dark:
            NSAppearance(named: .darkAqua)
        }
    }
}
