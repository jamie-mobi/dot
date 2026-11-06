//
//  CommandShortcut.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct CommandShortcut: Hashable, Sendable, Codable {
    // MARK: - Stored

    public let key: String
    public let modifiers: Set<ShortcutModifier>

    // MARK: - Init

    public init(_ key: String, _ modifiers: Set<ShortcutModifier> = [.command]) {
        self.key = key.lowercased()
        self.modifiers = modifiers
    }

    // MARK: - Derived

    public var functionKeyNumber: Int? {
        guard key.first == "f" else {
            return nil
        }

        return Int(key.dropFirst())
    }

    public var text: String {
        keyCaps.joined()
    }

    public var keyCaps: [String] {
        ShortcutModifier.allCases.filter(modifiers.contains).map(\.symbol) + [keySymbol]
    }

    private var keySymbol: String {
        switch key {
        case "tab":
            "⇥"
        case "return":
            "↩"
        case "space":
            "Space"
        case "delete":
            "⌫"
        case "escape":
            "⎋"
        case "up":
            "↑"
        case "down":
            "↓"
        case "left":
            "←"
        case "right":
            "→"
        default:
            key.uppercased()
        }
    }
}
