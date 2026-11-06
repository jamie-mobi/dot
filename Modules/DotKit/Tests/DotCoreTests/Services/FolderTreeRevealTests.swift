//
//  FolderTreeRevealTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Reveal in Folder Tree", .tags(.service))
@MainActor
struct FolderTreeRevealTests {
    @Test("shows the open Note and asks the tree to reveal it")
    func reveal() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Soil.md"))
        harness.navigation.showSearch()

        harness.navigation.revealInFolderTree()

        #expect(harness.navigation.destination == .note)
        #expect(harness.navigation.folderTreeReveal == 1)
    }

    @Test("does nothing with no Note open")
    func nothingOpen() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        harness.navigation.showSearch()

        harness.navigation.revealInFolderTree()

        #expect(harness.navigation.destination == .search)
        #expect(harness.navigation.folderTreeReveal == 0)
    }
}
