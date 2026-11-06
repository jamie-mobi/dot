//
//  SearchServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("SearchService with a fixture Pack", .tags(.service))
@MainActor
struct SearchServiceTests {
    // MARK: - Helpers

    private static func results(_ query: String, in pack: FixturePack) async -> [SearchResult] {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        defer { try? FileManager().removeItem(at: harness.indexFolder) }
        await harness.openPack()
        await harness.index.sync()
        harness.search.query = query
        await harness.search.search()
        guard case let .results(results) = harness.search.loadState else {
            return []
        }
        return results
    }

    private static func names(_ query: String, in pack: FixturePack) async -> [String] {
        await results(query, in: pack).map(\.path.name)
    }

    // MARK: - Tests

    @Test("finds a word in every Note that has it, with the line in context")
    func word() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        let results = await Self.results("compost", in: pack)

        #expect(results.map(\.path.name) == ["Soil", "Tomatoes"])
        #expect(results.first?.lines.first?.text == "Compost improves every kind. ^compost-rule")
        #expect(results.first?.lines.first?.line == 16)
    }

    @Test("all words must match, and the last word matches as a prefix while typing")
    func andPrefix() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        #expect(await Self.names("water morn", in: pack) == ["Gardening Basics"])
    }

    @Test("a quoted phrase matches words in order")
    func phrase() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        #expect(await Self.names(#""organic matter""#, in: pack) == ["Soil"])
        #expect(await Self.names(#""matter organic""#, in: pack).isEmpty)
    }

    @Test("[property:value] finds the Notes whose Property has the value, with the line shown")
    func property() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        let results = await Self.results("[difficulty:easy]", in: pack)

        #expect(results.map(\.path.name) == ["Gardening Basics"])
        #expect(results.first?.lines.first?.text == "difficulty: easy")
        #expect(await Self.names("[difficulty:hard]", in: pack).isEmpty)
        #expect(Set(await Self.names("[planted]", in: pack)) == ["Tomatoes"])
        #expect(await Self.names("-[difficulty] [planted] tag:garden", in: pack) == ["Tomatoes"])
    }

    @Test("tag: finds the Tag and its children, from the body and the tags Property")
    func tag() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        #expect(Set(await Self.names("tag:#garden", in: pack)) == ["Soil", "Tomatoes", "Gardening Basics"])
        #expect(await Self.names("tag:#garden/harvest", in: pack) == ["Tomatoes"])
    }

    @Test("path:, file: and -word narrow the results")
    func filters() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        #expect(await Self.names("soil path:Reading", in: pack) == ["The Soil Book"])
        #expect(await Self.names("file:roadmap", in: pack) == ["Dot Roadmap"])
        #expect(await Self.names("soil -tomatoes", in: pack).contains("Tomatoes") == false)
    }

    @Test("accents and case are ignored")
    func folding() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }

        #expect(await Self.names("COMPÔST", in: pack) == ["Soil", "Tomatoes"])
    }

    @Test("Match Case drops a Note whose only match differs in case, and changing it searches again")
    func matchCase() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        defer { try? FileManager().removeItem(at: harness.indexFolder) }
        await harness.openPack()
        await harness.index.sync()
        harness.search.query = "Compost"
        await harness.search.search()

        harness.search.options = SearchOptions(matchesCase: true)
        await harness.search.waitForSearch()

        guard case let .results(results) = harness.search.loadState else {
            Issue.record("no results")
            return
        }
        #expect(results.map(\.path.name) == ["Soil"])
    }

    @Test("typing schedules one search after a short pause")
    func debounce() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        defer { try? FileManager().removeItem(at: harness.indexFolder) }
        await harness.openPack()
        await harness.index.sync()

        harness.search.query = "c"
        harness.search.query = "co"
        harness.search.query = "compost"
        await harness.search.waitForSearch()

        guard case let .results(results) = harness.search.loadState else {
            Issue.record("Expected results, got \(harness.search.loadState)")
            return
        }
        #expect(results.map(\.path.name) == ["Soil", "Tomatoes"])
    }
}
