//
//  ShortcutUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum ShortcutUseCase {
    // MARK: - Reads

    public static func effective(
        for id: String,
        fallback: CommandShortcut?,
        saved: [String: ShortcutChoice]
    ) -> CommandShortcut? {
        switch saved[id] {
        case let .custom(shortcut):
            shortcut
        case .removed:
            nil
        case nil:
            fallback
        }
    }

    // MARK: - Checks

    public static func problem(with shortcut: CommandShortcut) -> ShortcutProblem? {
        guard shortcut.functionKeyNumber == nil, shortcut.modifiers.isDisjoint(with: [.command, .control]) else {
            return nil
        }

        return .needsModifier
    }

    // MARK: - Changes

    public static func saving(
        _ shortcut: CommandShortcut,
        for id: String,
        fallback: CommandShortcut?,
        in saved: [String: ShortcutChoice]
    ) -> [String: ShortcutChoice] {
        var next = saved
        next[id] = shortcut == fallback ? nil : .custom(shortcut)
        return next
    }
}
