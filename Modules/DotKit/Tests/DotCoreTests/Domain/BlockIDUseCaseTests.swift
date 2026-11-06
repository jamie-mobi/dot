//
//  BlockIDUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Block ids: paragraphs, new ids and adding them", .tags(.domain))
struct BlockIDUseCaseTests {
    // MARK: - Helpers

    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64

        mutating func next() -> UInt64 {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return state
        }
    }

    // MARK: - Candidates

    @Test("lists paragraphs and list items without an id, and skips headings, tables, code, rules and frontmatter")
    func candidates() {
        let text = """
        ---
        title: Soil
        ---
        # Soil

        First line of a paragraph
        that goes on here.

        - [ ] a task item
        - a list item ^has-id

        | a | b |
        | - | - |

        ```
        code line
        ```

        ---
        Compost improves every kind. ^compost-rule

        Last **bold** words.
        """

        #expect(BlockIDUseCase.candidates(in: text) == [
            BlockCandidate(line: 6, text: "First line of a paragraph"),
            BlockCandidate(line: 8, text: "a task item"),
            BlockCandidate(line: 21, text: "Last bold words.")
        ])
    }

    // MARK: - New id

    @Test("a new id is six lowercase letters and digits and never one the Note has")
    func newID() {
        var generator = SeededGenerator(state: 7)
        let first = BlockIDUseCase.newID(avoiding: [], using: &generator)
        var again = SeededGenerator(state: 7)

        let second = BlockIDUseCase.newID(avoiding: [first], using: &again)

        #expect(first.count == BlockIDUseCase.idLength)
        #expect(first.allSatisfy { $0.isLowercase || $0.isNumber })
        #expect(second != first)
    }

    // MARK: - Adding

    @Test("adds the id at the end of the line and leaves every other byte alone")
    func adding() throws {
        let text = "One\r\nTwo  \r\nThree\n"

        let updated = try #require(BlockIDUseCase.adding("abc123", toLine: 1, in: text))

        #expect(updated == "One\r\nTwo ^abc123\r\nThree\n")
    }

    @Test("refuses a line that already has an id, an empty line or a line that is not there")
    func refuses() {
        #expect(BlockIDUseCase.adding("abc123", toLine: 0, in: "Done ^old") == nil)
        #expect(BlockIDUseCase.adding("abc123", toLine: 1, in: "A\n\nB") == nil)
        #expect(BlockIDUseCase.adding("abc123", toLine: 9, in: "A") == nil)
    }
}
