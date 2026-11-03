//
//  VaultHomeServiceTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("VaultHomeService", .tags(.service))
@MainActor
struct VaultHomeServiceTests {
    // MARK: - Tests

    @Test("builds cards from the Index: newest first, with preview, date and first Tag")
    func cards() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        try FileManager().setAttributes([.modificationDate: Date.now.addingTimeInterval(60)], ofItemAtPath: vault.url("Soil.md").path)
        await harness.openVault()
        await harness.index.sync()
        await harness.links.sync()

        await harness.graph.home.refresh()
        let home = harness.graph.home.home

        let soil = try #require(home.recent.first)
        #expect(soil.path == NotePath("Soil.md"))
        #expect(soil.preview.first == "Soil is a mix of sand, silt, clay and organic matter.")
        #expect(soil.tag == "garden")
        #expect(home.noteCount == harness.vault.entries.count { $0.kind == .note })
        #expect(home.groups.map(\.folder).contains(NotePath("Projects")))
    }
}
