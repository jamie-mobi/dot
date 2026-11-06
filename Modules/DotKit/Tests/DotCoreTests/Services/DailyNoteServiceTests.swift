//
//  DailyNoteServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("DailyNoteService", .tags(.service))
@MainActor
struct DailyNoteServiceTests {
    // MARK: - Helpers

    private static func service(_ harness: ServiceHarness, on date: Date) -> DailyNoteService {
        DailyNoteService(
            pack: harness.pack,
            links: harness.links,
            navigation: harness.navigation,
            clock: FixedClock(now: date, timeZone: TimeZone(identifier: "Australia/Sydney") ?? .gmt)
        )
    }

    // MARK: - Tests

    @Test("creates a missing Daily Note from the Pack's Template and opens it")
    func creates() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()

        let opened = await Self.service(harness, on: Date(timeIntervalSince1970: 1_793_200_000)).openToday()

        #expect(opened == NotePath("Daily Notes/2026-10-29.md"))
        #expect(harness.notes.path == opened)
        #expect(try pack.text("Daily Notes/2026-10-29.md").hasPrefix("# 2026-10-29\n\n## Tasks"))
    }

    @Test("opens an existing Daily Note without changing it")
    func opensExisting() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let before = try pack.text("Daily Notes/2026-10-26.md")
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()

        let service = Self.service(harness, on: Date(timeIntervalSince1970: 1_793_000_000))
        await service.openToday()
        await service.openToday()
        await harness.notes.flush()

        #expect(harness.notes.path == NotePath("Daily Notes/2026-10-26.md"))
        #expect(try pack.text("Daily Notes/2026-10-26.md") == before)
    }
}
