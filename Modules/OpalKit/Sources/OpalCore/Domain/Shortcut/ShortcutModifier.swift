//
//  ShortcutModifier.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum ShortcutModifier: String, Hashable, Sendable, Codable, CaseIterable {
    case control
    case option
    case shift
    case command

    // MARK: - Display

    public var symbol: String {
        switch self {
        case .control:
            "⌃"
        case .option:
            "⌥"
        case .shift:
            "⇧"
        case .command:
            "⌘"
        }
    }
}
