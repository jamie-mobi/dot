//
//  OpenNoteLinksTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("LinkService open Note", .tags(.service))
@MainActor
struct OpenNoteLinksTests {
    // MARK: - Helpers

    private static func harness(_ pack: FixturePack) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("a small Note is analysed off the main actor without a pause, and follows each edit")
    func smallNote() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        harness.links.openNoteChanged(NotePath("Welcome.md"), text: "# Welcome\n\nSee [[Soil]] and [[Nowhere]].\n")

        await harness.links.waitForOpenNote()
        #expect(harness.links.openNote?.parsed.headings.map(\.text) == ["Welcome"])
        #expect(harness.links.openNote?.styles.filter(\.kind.isLink).map(\.kind) == [.link(isResolved: true), .link(isResolved: false)])

        harness.links.openNoteChanged(NotePath("Welcome.md"), text: "# Hello\n")

        await harness.links.waitForOpenNote()
        #expect(harness.links.openNote?.parsed.headings.map(\.text) == ["Hello"])
        #expect(harness.links.openNote?.styles.filter(\.kind.isLink).isEmpty == true)
    }

    @Test("a large Note is parsed off the main actor after a pause")
    func largeNote() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        let text = "# Big\n" + String(repeating: "Text about [[Soil]].\n", count: LinkService.largeNoteLimit / 10)

        harness.links.openNoteChanged(NotePath("Big.md"), text: text)
        #expect(harness.links.openNote == nil)

        await harness.links.waitForOpenNote()
        #expect(harness.links.openNote?.path == NotePath("Big.md"))
        #expect(harness.links.openNote?.textLength == text.utf16.count)
        #expect(harness.links.openNote?.styles.filter(\.kind.isLink).allSatisfy { $0.kind == .link(isResolved: true) } == true)
        #expect(harness.links.openNote?.styles.contains { $0.kind == .heading(level: 1) } == true)
        let locations = harness.links.openNote?.styles.map(\.span.location) ?? []
        #expect(locations == locations.sorted())
    }

    @Test("closing the Note clears it")
    func close() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        harness.links.openNoteChanged(NotePath("Welcome.md"), text: "# Welcome\n")
        await harness.links.waitForOpenNote()

        harness.links.openNoteChanged(nil, text: "")

        #expect(harness.links.openNote == nil)
    }

    @Test("a Link map rebuild recolours the open Note's Links")
    func rebuildRecolours() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        harness.links.openNoteChanged(NotePath("Welcome.md"), text: "See [[Peas]].\n")
        await harness.links.waitForOpenNote()
        #expect(harness.links.openNote?.styles.filter(\.kind.isLink).first?.kind == .link(isResolved: false))

        try pack.write("# Peas\n", to: "Peas.md")
        await harness.pack.handleExternalChanges([NotePath("Peas.md")])
        await harness.links.sync()
        await harness.links.waitForOpenNote()

        #expect(harness.links.openNote?.styles.filter(\.kind.isLink).first?.kind == .link(isResolved: true))
    }

    @Test("NoteService keeps the open Note's Links current through open, edit and close")
    func followsNoteService() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        await harness.notes.open(NotePath("Tomatoes.md"))
        await harness.links.waitForOpenNote()
        #expect(harness.links.openNote?.path == NotePath("Tomatoes.md"))
        #expect(harness.links.openNote?.parsed.headings.map(\.text) == ["Tomatoes", "Watering", "Harvest"])

        harness.notes.edit("# Tomatoes\n\n## Pruning\n")
        await harness.links.waitForOpenNote()
        #expect(harness.links.openNote?.parsed.headings.map(\.text) == ["Tomatoes", "Pruning"])

        await harness.notes.close()
        #expect(harness.links.openNote == nil)
    }
}
