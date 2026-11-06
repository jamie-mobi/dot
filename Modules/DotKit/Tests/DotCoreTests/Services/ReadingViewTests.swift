//
//  ReadingViewTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Reading view", .tags(.service))
@MainActor
struct ReadingViewTests {
    @Test("reading a Note never writes it")
    func neverWrites() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        let path = NotePath("Welcome.md")
        let url = pack.url(path.rawValue)
        let before = try Data(contentsOf: url)
        let date = try FileManager().attributesOfItem(atPath: url.path)[.modificationDate] as? Date

        await harness.navigation.open(path)
        harness.navigation.isReadingView = true
        let text = try #require(harness.notes.loadState.note?.text)
        let blocks = await harness.links.readingBlocks(of: path, text: text)
        await harness.notes.flush()
        harness.navigation.isReadingView = false
        await harness.notes.flush()

        #expect(blocks.contains { $0.isHeading })
        #expect(try Data(contentsOf: url) == before)
        #expect(try FileManager().attributesOfItem(atPath: url.path)[.modificationDate] as? Date == date)
    }
}
