//
//  FolderColourServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("FolderColourService", .tags(.service))
@MainActor
struct FolderColourServiceTests {
    // MARK: - Helpers

    private static func setUp(_ pack: FixturePack) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("a colour is saved per Pack in Dot's store, and None removes it")
    func setAndClear() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let root = try #require(harness.pack.store?.rootURL)
        let colours = harness.graph.folderColours

        await colours.set(.blue, for: NotePath("Projects"))
        #expect(await harness.folderColourStore.folderColours(forPackAt: root) == [NotePath("Projects"): .blue])
        #expect(colours.colour(for: NotePath("Projects/Dot/Dot Roadmap.md")) == .blue)

        await colours.set(nil, for: NotePath("Projects"))
        #expect(await harness.folderColourStore.folderColours(forPackAt: root) == [:])
        #expect(FileManager().fileExists(atPath: pack.url(".obsidian/folder-colours.json").path) == false)
    }

    @Test("renaming a coloured Folder in Dot keeps its colour")
    func renameKeepsColour() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        await harness.graph.folderColours.set(.purple, for: NotePath("Projects"))

        let plan = try harness.graph.renames.plan(renaming: NotePath("Projects"), to: "Work").get()
        try await harness.graph.renames.perform(plan, from: NotePath("Projects"), updatingLinks: false)

        #expect(harness.graph.folderColours.ownColour(of: NotePath("Work")) == .purple)
        #expect(harness.graph.folderColours.ownColour(of: NotePath("Projects")) == nil)
    }

    @Test("moving a coloured Folder to the Trash drops its colour")
    func trashDropsColour() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        await harness.graph.folderColours.set(.amber, for: NotePath("Projects"))

        try await harness.graph.renames.trash(NotePath("Projects"))

        #expect(harness.graph.folderColours.colours.isEmpty)
    }
}
