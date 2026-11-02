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

    @Test("macOS's and editing's shortcuts are refused with a reason", arguments: [
        (CommandShortcut("q"), ShortcutProblem.usedByMacOS),
        (CommandShortcut("h"), .usedByMacOS),
        (CommandShortcut("m"), .usedByMacOS),
        (CommandShortcut("c"), .usedForEditing),
        (CommandShortcut("v"), .usedForEditing),
        (CommandShortcut("x"), .usedForEditing),
        (CommandShortcut("z"), .usedForEditing),
        (CommandShortcut("z", [.command, .shift]), .usedForEditing),
        (CommandShortcut("a"), .usedForEditing),
        (CommandShortcut("f"), .usedForEditing),
        (CommandShortcut("g"), .usedForEditing)
    ])
    func reserved(shortcut: CommandShortcut, problem: ShortcutProblem) {
        #expect(ShortcutUseCase.problem(with: shortcut) == problem)
    }

    @Test("⇧⌘F and ⌃C are not reserved")
    func notReserved() {
        #expect(ShortcutUseCase.problem(with: CommandShortcut("f", [.command, .shift])) == nil)
        #expect(ShortcutUseCase.problem(with: CommandShortcut("c", [.control])) == nil)
    }

    @Test("a conflict names the command that holds the shortcut, including a default never changed")
    func holder() {
        let fallbacks = ["newNote": Self.commandN, "newTab": CommandShortcut("t")]
        let ids = ["newNote", "newTab", "save"]
        let check: (CommandShortcut, [String: ShortcutChoice]) -> String? = { shortcut, saved in
            ShortcutUseCase.holder(of: shortcut, otherThan: "save", fallbacks: fallbacks, saved: saved, ids: ids)
        }

        #expect(check(CommandShortcut("t"), [:]) == "newTab")
        #expect(check(Self.commandK, ["newNote": .custom(Self.commandK)]) == "newNote")
        #expect(check(CommandShortcut("t"), ["newTab": .removed]) == nil)
        #expect(ShortcutUseCase.holder(of: Self.commandN, otherThan: "newNote", fallbacks: fallbacks, saved: [:], ids: ids) == nil)
    }

    @Test("a saved id that names no command is not a conflict")
    func staleHolder() {
        #expect(ShortcutUseCase.holder(of: Self.commandK, otherThan: "save", fallbacks: [:], saved: ["gone": .custom(Self.commandK)], ids: ["save"]) == nil)
    }

    // MARK: - Changes

    @Test("Replace gives the shortcut to this command and leaves the other with none")
    func replacing() {
        let saved = ShortcutUseCase.replacing("newTab", with: CommandShortcut("t"), for: "newNote", fallback: Self.commandN, in: [:])

        #expect(saved == ["newNote": .custom(CommandShortcut("t")), "newTab": .removed])
        #expect(ShortcutUseCase.effective(for: "newTab", fallback: CommandShortcut("t"), saved: saved) == nil)
    }

    @Test("saving stores the shortcut; saving the default stores nothing")
    func saving() {
        let saved = ShortcutUseCase.saving(Self.commandK, for: "newNote", fallback: Self.commandN, in: [:])
        #expect(saved == ["newNote": .custom(Self.commandK)])
        #expect(ShortcutUseCase.saving(Self.commandN, for: "newNote", fallback: Self.commandN, in: saved).isEmpty)
    }

    @Test("removing a default is remembered apart from having no saved value, and survives a round trip")
    func removing() throws {
        let saved = ShortcutUseCase.removing(for: "newNote", fallback: Self.commandN, in: [:])
        #expect(saved == ["newNote": .removed])
        #expect(ShortcutUseCase.effective(for: "newNote", fallback: Self.commandN, saved: saved) == nil)

        var settings = OpalSettings()
        settings.shortcuts = saved
        let loaded = try JSONDecoder().decode(OpalSettings.self, from: JSONEncoder().encode(settings))
        #expect(ShortcutUseCase.effective(for: "newNote", fallback: Self.commandN, saved: loaded.shortcuts) == nil)
    }

    @Test("removing from a command with no default leaves nothing to restore")
    func removingWithoutDefault() {
        let saved: [String: ShortcutChoice] = ["duplicateNote": .custom(Self.commandK)]

        #expect(ShortcutUseCase.removing(for: "duplicateNote", fallback: nil, in: saved).isEmpty)
    }

    @Test("restoring returns the command to its default")
    func restoring() {
        let saved = ShortcutUseCase.restoring(for: "newNote", in: ["newNote": .removed, "save": .removed])

        #expect(saved == ["save": .removed])
        #expect(ShortcutUseCase.effective(for: "newNote", fallback: Self.commandN, saved: saved) == Self.commandN)
    }

    @Test("a restored default held by another command is a conflict")
    func restoreConflict() {
        let saved: [String: ShortcutChoice] = ["newNote": .removed, "save": .custom(Self.commandN)]

        #expect(ShortcutUseCase.holder(of: Self.commandN, otherThan: "newNote", fallbacks: ["newNote": Self.commandN], saved: saved, ids: ["newNote", "save"]) == "save")
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
