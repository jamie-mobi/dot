//
//  ShortcutChoice.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum ShortcutChoice: Hashable, Sendable, Codable {
    case custom(CommandShortcut)
    case removed
}
