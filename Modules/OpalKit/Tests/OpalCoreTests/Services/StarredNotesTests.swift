//
//  StarredNotesTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("Starred Notes", .tags(.service))
@MainActor
struct StarredNotesTests {
    // MARK: - Helpers

    private static func setUp(_ vault: FixtureVault) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVaultWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("starring saves the Note per Vault in Opal's store and writes nothing to the Vault")
    func starSaves() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        let root = try #require(harness.vault.store?.rootURL)
        let before = try vault.text("Soil.md")

        await harness.graph.stars.toggle(NotePath("Soil.md"))
        await harness.graph.stars.toggle(NotePath("Tomatoes.md"))

        #expect(harness.graph.stars.notes == [NotePath("Soil.md"), NotePath("Tomatoes.md")])
        #expect(await harness.starred.starredNotes(forVaultAt: root) == [NotePath("Soil.md"), NotePath("Tomatoes.md")])
        #expect(try vault.text("Soil.md") == before)
        #expect(FileManager().fileExists(atPath: vault.url(".obsidian/bookmarks.json").path) == false)
    }

    @Test("starring again removes the star")
    func unstar() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        let root = try #require(harness.vault.store?.rootURL)

        await harness.graph.stars.toggle(NotePath("Soil.md"))
        await harness.graph.stars.toggle(NotePath("Soil.md"))

        #expect(harness.graph.stars.isStarred(NotePath("Soil.md")) == false)
        #expect(await harness.starred.starredNotes(forVaultAt: root) == [])
    }

    @Test("a rename in Opal keeps the star on the new name")
    func renameKeepsStar() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        let root = try #require(harness.vault.store?.rootURL)
        await harness.graph.stars.toggle(NotePath("Soil.md"))

        let plan = try harness.graph.renames.plan(renaming: NotePath("Soil.md"), to: "Earth").get()
        try await harness.graph.renames.perform(plan, from: NotePath("Soil.md"), updatingLinks: false)

        #expect(harness.graph.stars.notes == [NotePath("Earth.md")])
        #expect(await harness.starred.starredNotes(forVaultAt: root) == [NotePath("Earth.md")])
    }

    @Test("moving a Note to the Trash drops its star")
    func trashDropsStar() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        await harness.graph.stars.toggle(NotePath("Soil.md"))

        try await harness.graph.renames.trash(NotePath("Soil.md"))

        #expect(harness.graph.stars.notes.isEmpty)
    }

    @Test("stars come back when the Vault opens again")
    func reload() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        let root = try #require(harness.vault.store?.rootURL)
        await harness.starred.setStarredNotes([NotePath("Tomatoes.md")], forVaultAt: root)

        await harness.graph.stars.load()

        #expect(harness.graph.stars.notes == [NotePath("Tomatoes.md")])
    }
}
