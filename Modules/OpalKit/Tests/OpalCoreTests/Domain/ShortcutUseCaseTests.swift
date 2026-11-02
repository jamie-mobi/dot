//
//  ShortcutUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("ShortcutUseCase", .tags(.domain))
struct ShortcutUseCaseTests {
    // MARK: - Fixtures

    private static let commandN = CommandShortcut("n")
    private static let commandK = CommandShortcut("k")

    // MARK: - Reads

    @Test("a command with no saved value uses its default")
    func usesDefault() {
        #expect(ShortcutUseCase.effective(for: "newNote", fallback: Self.commandN, saved: [:]) == Self.commandN)
    }

    @Test("a saved shortcut wins over the default")
    func usesSaved() {
        #expect(ShortcutUseCase.effective(for: "newNote", fallback: Self.commandN, saved: ["newNote": .custom(Self.commandK)]) == Self.commandK)
    }

    @Test("a saved id that names no command is ignored")
    func ignoresUnknownID() {
        let saved: [String: ShortcutChoice] = ["goneCommand": .custom(Self.commandK)]

        #expect(ShortcutUseCase.effective(for: "newNote", fallback: Self.commandN, saved: saved) == Self.commandN)
    }

    // MARK: - Checks

    @Test("a shortcut needs ⌘ or ⌃, or is a function key", arguments: [
        (CommandShortcut("k", []), false),
        (CommandShortcut("k", [.shift, .option]), false),
        (CommandShortcut("k", [.command]), true),
        (CommandShortcut("k", [.control]), true),
        (CommandShortcut("f5", []), true),
        (CommandShortcut("f", []), false)
    ])
    func needsModifier(shortcut: CommandShortcut, isAllowed: Bool) {
        #expect((ShortcutUseCase.problem(with: shortcut) == nil) == isAllowed)
    }

    // MARK: - Changes

    @Test("saving stores the shortcut; saving the default stores nothing")
    func saving() {
        let saved = ShortcutUseCase.saving(Self.commandK, for: "newNote", fallback: Self.commandN, in: [:])
        #expect(saved == ["newNote": .custom(Self.commandK)])
        #expect(ShortcutUseCase.saving(Self.commandN, for: "newNote", fallback: Self.commandN, in: saved).isEmpty)
    }

    // MARK: - Words

    @Test("shortcut text puts modifiers in Apple's order", arguments: [
        (CommandShortcut("p", [.command, .shift]), "⇧⌘P"),
        (CommandShortcut("tab", [.shift, .control]), "⌃⇧⇥"),
        (CommandShortcut("0", [.option, .command]), "⌥⌘0"),
        (CommandShortcut("[", [.command]), "⌘[")
    ])
    func text(shortcut: CommandShortcut, expected: String) {
        #expect(shortcut.text == expected)
    }

    // MARK: - Settings

    @Test("saved shortcuts survive a round trip, and older settings still load")
    func settingsRoundTrip() throws {
        var settings = OpalSettings()
        settings.shortcuts = ["newNote": .custom(Self.commandK), "save": .removed]
        let data = try JSONEncoder().encode(settings)
        #expect(try JSONDecoder().decode(OpalSettings.self, from: data).shortcuts == settings.shortcuts)

        let older = Data(#"{"dailyFolder":"Journal"}"#.utf8)
        let loaded = try JSONDecoder().decode(OpalSettings.self, from: older)
        #expect(loaded.shortcuts.isEmpty)
        #expect(loaded.dailyFolder == "Journal")
    }
}
