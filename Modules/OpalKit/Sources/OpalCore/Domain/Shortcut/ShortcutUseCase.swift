//
//  ShortcutUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum ShortcutUseCase {
    // MARK: - Constants

    private static let macOS: Set<CommandShortcut> = [CommandShortcut("q"), CommandShortcut("h"), CommandShortcut("m")]
    private static let editing: Set<CommandShortcut> = [
        CommandShortcut("c"), CommandShortcut("v"), CommandShortcut("x"), CommandShortcut("z"),
        CommandShortcut("z", [.command, .shift]), CommandShortcut("a"), CommandShortcut("f"), CommandShortcut("g")
    ]

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
        if macOS.contains(shortcut) {
            return .usedByMacOS
        }

        if editing.contains(shortcut) {
            return .usedForEditing
        }

        guard shortcut.functionKeyNumber == nil, shortcut.modifiers.isDisjoint(with: [.command, .control]) else {
            return nil
        }

        return .needsModifier
    }

    public static func holder(
        of shortcut: CommandShortcut,
        otherThan id: String,
        fallbacks: [String: CommandShortcut],
        saved: [String: ShortcutChoice],
        ids: [String]
    ) -> String? {
        ids.first { candidate in
            candidate != id && effective(for: candidate, fallback: fallbacks[candidate], saved: saved) == shortcut
        }
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

    public static func replacing(
        _ other: String,
        with shortcut: CommandShortcut,
        for id: String,
        fallback: CommandShortcut?,
        in saved: [String: ShortcutChoice]
    ) -> [String: ShortcutChoice] {
        var next = saving(shortcut, for: id, fallback: fallback, in: saved)
        next[other] = .removed
        return next
    }
}
