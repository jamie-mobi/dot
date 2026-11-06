//
//  StarredNotesTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Starred Notes", .tags(.service))
@MainActor
struct StarredNotesTests {
    // MARK: - Helpers

    private static func setUp(_ pack: FixturePack) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("starring saves the Note per Pack in Dot's store and writes nothing to the Pack")
    func starSaves() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let root = try #require(harness.pack.store?.rootURL)
        let before = try pack.text("Soil.md")

        await harness.graph.stars.toggle(NotePath("Soil.md"))
        await harness.graph.stars.toggle(NotePath("Tomatoes.md"))

        #expect(harness.graph.stars.notes == [NotePath("Soil.md"), NotePath("Tomatoes.md")])
        #expect(await harness.starred.starredNotes(forPackAt: root) == [NotePath("Soil.md"), NotePath("Tomatoes.md")])
        #expect(try pack.text("Soil.md") == before)
        #expect(FileManager().fileExists(atPath: pack.url(".obsidian/bookmarks.json").path) == false)
    }

    @Test("starring again removes the star")
    func unstar() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let root = try #require(harness.pack.store?.rootURL)

        await harness.graph.stars.toggle(NotePath("Soil.md"))
        await harness.graph.stars.toggle(NotePath("Soil.md"))

        #expect(harness.graph.stars.isStarred(NotePath("Soil.md")) == false)
        #expect(await harness.starred.starredNotes(forPackAt: root) == [])
    }

    @Test("a rename in Dot keeps the star on the new name")
    func renameKeepsStar() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let root = try #require(harness.pack.store?.rootURL)
        await harness.graph.stars.toggle(NotePath("Soil.md"))

        let plan = try harness.graph.renames.plan(renaming: NotePath("Soil.md"), to: "Earth").get()
        try await harness.graph.renames.perform(plan, from: NotePath("Soil.md"), updatingLinks: false)

        #expect(harness.graph.stars.notes == [NotePath("Earth.md")])
        #expect(await harness.starred.starredNotes(forPackAt: root) == [NotePath("Earth.md")])
    }

    @Test("moving a Note to the Trash drops its star")
    func trashDropsStar() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        await harness.graph.stars.toggle(NotePath("Soil.md"))

        try await harness.graph.renames.trash(NotePath("Soil.md"))

        #expect(harness.graph.stars.notes.isEmpty)
    }

    @Test("stars come back when the Pack opens again")
    func reload() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let root = try #require(harness.pack.store?.rootURL)
        await harness.starred.setStarredNotes([NotePath("Tomatoes.md")], forPackAt: root)

        await harness.graph.stars.load()

        #expect(harness.graph.stars.notes == [NotePath("Tomatoes.md")])
    }
}
