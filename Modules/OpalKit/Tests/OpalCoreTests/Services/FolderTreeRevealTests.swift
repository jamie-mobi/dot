//
//  FolderTreeRevealTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("Reveal in Folder Tree", .tags(.service))
@MainActor
struct FolderTreeRevealTests {
    @Test("switches the sidebar to Files and asks the tree to reveal the open Note")
    func reveal() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()
        await harness.navigation.open(NotePath("Soil.md"))
        harness.navigation.sidebarPane = .search

        harness.navigation.revealInFolderTree()

        #expect(harness.navigation.sidebarPane == .files)
        #expect(harness.navigation.folderTreeReveal == 1)
    }

    @Test("does nothing with no Note open")
    func nothingOpen() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()
        harness.navigation.sidebarPane = .tags

        harness.navigation.revealInFolderTree()

        #expect(harness.navigation.sidebarPane == .tags)
        #expect(harness.navigation.folderTreeReveal == 0)
    }
}
