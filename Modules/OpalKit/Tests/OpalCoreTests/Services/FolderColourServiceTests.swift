//
//  FolderColourServiceTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("FolderColourService", .tags(.service))
@MainActor
struct FolderColourServiceTests {
    // MARK: - Helpers

    private static func setUp(_ vault: FixtureVault) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVaultWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("a colour is saved per Vault in Opal's store, and None removes it")
    func setAndClear() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        let root = try #require(harness.vault.store?.rootURL)
        let colours = harness.graph.folderColours

        await colours.set(.blue, for: NotePath("Projects"))
        #expect(await harness.folderColourStore.folderColours(forVaultAt: root) == [NotePath("Projects"): .blue])
        #expect(colours.colour(for: NotePath("Projects/Opal/Opal Roadmap.md")) == .blue)

        await colours.set(nil, for: NotePath("Projects"))
        #expect(await harness.folderColourStore.folderColours(forVaultAt: root) == [:])
        #expect(FileManager().fileExists(atPath: vault.url(".obsidian/folder-colours.json").path) == false)
    }

    @Test("renaming a coloured Folder in Opal keeps its colour")
    func renameKeepsColour() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        await harness.graph.folderColours.set(.purple, for: NotePath("Projects"))

        let plan = try harness.graph.renames.plan(renaming: NotePath("Projects"), to: "Work").get()
        try await harness.graph.renames.perform(plan, from: NotePath("Projects"), updatingLinks: false)

        #expect(harness.graph.folderColours.ownColour(of: NotePath("Work")) == .purple)
        #expect(harness.graph.folderColours.ownColour(of: NotePath("Projects")) == nil)
    }

    @Test("moving a coloured Folder to the Trash drops its colour")
    func trashDropsColour() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = await Self.setUp(vault)
        await harness.graph.folderColours.set(.amber, for: NotePath("Projects"))

        try await harness.graph.renames.trash(NotePath("Projects"))

        #expect(harness.graph.folderColours.colours.isEmpty)
    }
}
