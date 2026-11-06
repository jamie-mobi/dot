//
//  ExternalChangeTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Changes from outside with a fixture Pack", .tags(.service))
@MainActor
struct ExternalChangeTests {
    // MARK: - Helpers

    private static func harness(_ pack: FixturePack, watching: Bool = false) async -> ServiceHarness {
        let makeWatcher: (@Sendable (URL) -> any PackWatching)? = watching ? Self.makeWatcher : nil
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), makeWatcher: makeWatcher)
        await harness.openPackWithLinks()
        return harness
    }

    private nonisolated static func makeWatcher(_ rootURL: URL) -> any PackWatching {
        FSEventsPackWatcher(rootURL: rootURL)
    }

    private static func waitUntil(_ condition: @MainActor () -> Bool) async -> Bool {
        for _ in 0 ..< 60 {
            if condition() {
                return true
            }
            try? await Task.sleep(for: .milliseconds(50))
        }
        return condition()
    }

    // MARK: - Tree

    @Test("a file added by another app appears in the tree, through FSEvents")
    func watcherAddsFile() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack, watching: true)
        try await Task.sleep(for: .milliseconds(300))

        try pack.write("# Peas\n\nSee [[Soil]].\n", to: "Peas.md")

        #expect(await Self.waitUntil { harness.pack.kind(of: NotePath("Peas.md")) == .note })
        #expect(await Self.waitUntil {
            harness.links.map.backlinks(to: NotePath("Soil.md")).contains { $0.source == NotePath("Peas.md") }
        })
    }

    @Test("a file removed by another app leaves the tree")
    func removal() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        try FileManager().removeItem(at: pack.url("Areas/Health.md"))
        await harness.pack.handleExternalChanges([NotePath("Areas/Health.md")])

        #expect(harness.pack.kind(of: NotePath("Areas/Health.md")) == nil)
        #expect(harness.links.map.backlinks(to: NotePath("Tomatoes.md")).contains { $0.source == NotePath("Areas/Health.md") } == false)
    }

    // MARK: - Open Note

    @Test("an open Note with no unsaved edits reloads with the text on disk")
    func cleanReloads() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        await harness.notes.open(NotePath("Areas/Health.md"))

        try pack.write("# Health\n\nChanged in Obsidian.\n", to: "Areas/Health.md")
        await harness.pack.handleExternalChanges([NotePath("Areas/Health.md")])

        #expect(harness.notes.loadState.note?.text == "# Health\n\nChanged in Obsidian.\n")
        #expect(harness.notes.saveStatus == .saved)
    }

    @Test("an open Note with unsaved edits is not touched, and saving then reports a conflict")
    func dirtyKept() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        await harness.notes.open(NotePath("Areas/Health.md"))
        harness.notes.edit("# Health\n\nMy edit.\n")

        try pack.write("# Health\n\nTheir edit.\n", to: "Areas/Health.md")
        await harness.pack.handleExternalChanges([NotePath("Areas/Health.md")])
        #expect(harness.notes.loadState.note?.text == "# Health\n\nMy edit.\n")

        await harness.notes.flush()
        guard case .conflict = harness.notes.loadState else {
            Issue.record("Expected a conflict, got \(harness.notes.loadState)")
            return
        }
        #expect(try pack.text("Areas/Health.md") == "# Health\n\nTheir edit.\n")
    }

    @Test("Dot's own save causes no reload and no conflict")
    func ownSave() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        await harness.notes.open(NotePath("Areas/Health.md"))
        harness.notes.edit("# Health\n\nSaved by Dot.\n")
        await harness.notes.flush()

        await harness.pack.handleExternalChanges([NotePath("Areas/Health.md")])

        #expect(harness.notes.loadState == .editing(Note(path: NotePath("Areas/Health.md"), text: "# Health\n\nSaved by Dot.\n")))
        #expect(harness.notes.saveStatus == .saved)
    }

    @Test("changes in hidden Folders are ignored")
    func hiddenIgnored() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        let counter = CallCounter()
        harness.pack.onExternalChange = { _ in counter.count += 1 }

        await harness.pack.handleExternalChanges([NotePath(".obsidian/app.json"), NotePath(".git/index")])

        #expect(counter.count == 0)
    }
}

@MainActor
private final class CallCounter {
    var count = 0
}
