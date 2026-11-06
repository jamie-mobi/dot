//
//  IndexServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("IndexService with a fixture Pack", .tags(.service))
@MainActor
struct IndexServiceTests {
    // MARK: - Helpers

    private static func harness(_ pack: FixturePack) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        return harness
    }

    private static func notesOnDisk(_ harness: ServiceHarness) async throws -> Int {
        try await harness.store.noteStamps().count
    }

    // MARK: - Tests

    @Test("the first sync indexes every Note, outside the Pack")
    func firstSync() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        defer { try? FileManager().removeItem(at: harness.indexFolder) }

        await harness.index.sync()

        #expect(harness.index.loadState == .ready)
        let stamps = try #require(try await harness.index.store?.stamps())
        #expect(try await stamps.count == Self.notesOnDisk(harness))
        #expect(FileManager().fileExists(atPath: pack.url(".obsidian").path))
        #expect(try FileManager().contentsOfDirectory(atPath: pack.rootURL.path).contains { $0.hasSuffix(".sqlite") } == false)
    }

    @Test("a second open reads nothing when nothing changed, and picks up a changed Note")
    func incremental() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        defer { try? FileManager().removeItem(at: harness.indexFolder) }
        await harness.index.sync()
        let revision = harness.index.revision

        await harness.index.sync()
        #expect(harness.index.revision == revision + 1)

        let index = try #require(harness.index.store)
        let plan = try await IndexSyncPlanUseCase.plan(disk: harness.store.noteStamps(), indexed: index.stamps())
        #expect(plan.isEmpty)

        try pack.write("# Soil\n\nNow about [[Peas]].\n", to: "Soil.md")
        await harness.index.update([NotePath("Soil.md")])
        #expect(try await index.parsedNotes()[NotePath("Soil.md")]?.links.map(\.target) == ["Peas"])
    }

    @Test("deleting the Index loses nothing: the next sync rebuilds the same content")
    func rebuild() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        defer { try? FileManager().removeItem(at: harness.indexFolder) }
        await harness.index.sync()
        let before = try #require(try await harness.index.store?.parsedNotes())

        try FileManager().removeItem(at: harness.indexFolder)
        let fresh = await Self.harness(pack)
        let freshIndex = IndexService(pack: fresh.pack) { root throws(IndexError) in
            try GRDBIndexStore(folderURL: IndexLocation.folder(forPackAt: root, in: harness.indexFolder))
        }
        await freshIndex.sync()

        #expect(try await freshIndex.store?.parsedNotes() == before)
        try? FileManager().removeItem(at: fresh.indexFolder)
    }

    @Test("a saved edit and a removed file update the Index")
    func savesAndRemovals() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        defer { try? FileManager().removeItem(at: harness.indexFolder) }
        await harness.index.sync()

        await harness.notes.open(NotePath("Areas/Health.md"))
        harness.notes.edit("# Health\n\n## Sleep\n")
        await harness.notes.flush()
        try FileManager().removeItem(at: pack.url("Tomatoes.md"))
        await harness.pack.handleExternalChanges([NotePath("Tomatoes.md")])

        let parsed = try #require(try await harness.index.store?.parsedNotes())
        #expect(parsed[NotePath("Areas/Health.md")]?.headings.map(\.text) == ["Health", "Sleep"])
        #expect(parsed[NotePath("Tomatoes.md")] == nil)
    }
}
