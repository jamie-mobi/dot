//
//  SearchOptionsTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Search options: Match Case and scope", .tags(.domain))
struct SearchOptionsTests {
    // MARK: - Constants

    private static let text = """
    ---
    title: Soil notes
    status: draft
    ---
    Soil is alive.
    Good soil drains.
    """

    private static let path = NotePath("Soil.md")

    // MARK: - Helpers

    private static func result(_ query: String, _ options: SearchOptions) -> SearchResult {
        SearchSnippetUseCase.result(for: path, text: text, query: SearchQueryUseCase.parse(query), options: options)
    }

    // MARK: - Tests

    @Test("without options, every case and both parts of the Note match")
    func defaults() {
        let result = Self.result("soil", SearchOptions())

        #expect(result.matchCount == 3)
        #expect(result.lines.map(\.line) == [1, 4, 5])
    }

    @Test("Match Case keeps only lines with the same case")
    func matchCase() {
        let result = Self.result("Soil", SearchOptions(matchesCase: true))

        #expect(result.matchCount == 2)
        #expect(result.lines.map(\.line) == [1, 4])
    }

    @Test("Text only drops Property lines")
    func textOnly() {
        let result = Self.result("soil", SearchOptions(scope: .text))

        #expect(result.lines.map(\.kind) == [.text, .text])
        #expect(result.matchCount == 2)
    }

    @Test("Properties only keeps only Property lines")
    func propertiesOnly() {
        let result = Self.result("soil", SearchOptions(scope: .properties))

        #expect(result.lines.map(\.kind) == [.property])
        #expect(result.matchCount == 1)
    }

    @Test("a Note with no line left is not shown, unless no option is set")
    func shown() {
        let query = SearchQueryUseCase.parse("drains")
        let none = Self.result("drains", SearchOptions(scope: .properties))

        #expect(SearchSnippetUseCase.isShown(none, query: query, options: SearchOptions(scope: .properties)) == false)
        #expect(SearchSnippetUseCase.isShown(none, query: query, options: SearchOptions()))
        #expect(SearchSnippetUseCase.isShown(Self.result("drains", SearchOptions(scope: .text)), query: query, options: SearchOptions(scope: .text)))
    }

    @Test("a tag-only query is never dropped by the options")
    func tagOnly() {
        let query = SearchQueryUseCase.parse("tag:#garden")
        let result = SearchSnippetUseCase.result(for: Self.path, text: Self.text, query: query, options: SearchOptions(matchesCase: true))

        #expect(SearchSnippetUseCase.isShown(result, query: query, options: SearchOptions(matchesCase: true)))
    }
}
