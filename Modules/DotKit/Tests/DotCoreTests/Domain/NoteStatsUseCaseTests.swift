//
//  NoteStatsUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("NoteStatsUseCase", .tags(.domain))
struct NoteStatsUseCaseTests {
    // MARK: - Tests

    @Test("counts words in the body, not in the frontmatter")
    func words() {
        #expect(NoteStatsUseCase.words(in: "---\ntags: [garden, vegetables]\n---\n# Tomatoes\n\nGrow them in full sun.") == 6)
        #expect(NoteStatsUseCase.words(in: "") == 0)
    }

    @Test("a Link counts the words of its target and its alias")
    func linkWords() {
        #expect(NoteStatsUseCase.words(in: "In [[Soil|rich earth]].") == 4)
    }

    @Test("Created comes from the created Property, else the file date")
    func created() throws {
        let fileDate = Date(timeIntervalSinceReferenceDate: 0)
        let stats = NoteStatsUseCase.stats(text: "---\ncreated: 2026-03-14\n---\nHi", links: 4, backlinks: 3, fileCreated: fileDate)
        let expected = try Date.ISO8601FormatStyle().year().month().day().parse("2026-03-14")
        #expect(stats == NoteStats(words: 1, links: 4, backlinks: 3, created: expected))
        #expect(NoteStatsUseCase.stats(text: "Hi", links: 0, backlinks: 0, fileCreated: fileDate).created == fileDate)
    }
}
