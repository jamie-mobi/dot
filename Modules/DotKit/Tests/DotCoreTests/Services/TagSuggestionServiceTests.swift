//
//  TagSuggestionServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Tag suggestions", .tags(.service))
@MainActor
struct TagSuggestionServiceTests {
    // MARK: - Helpers

    private static var on: StubSettingsStore {
        var settings = DotSettings.defaults
        settings.suggestsTags = true
        return StubSettingsStore(settings)
    }

    private func openSoil(_ harness: ServiceHarness) async throws -> NoteDocument {
        await harness.openPackWithLinks()
        await harness.navigation.open(NotePath("Soil.md"))
        await harness.links.waitForOpenNote()
        return try #require(harness.notes.focused)
    }

    private func text(of document: NoteDocument) throws -> String {
        guard case let .editing(note) = document.loadState else {
            throw TagSuggestionError.failed
        }

        return note.text
    }

    // MARK: - Tests

    @Test("does nothing and asks no model while the setting is off")
    func off() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let suggester = StubTagSuggester(result: .success(["soil"]))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), tagSuggester: suggester)
        let document = try await openSoil(harness)

        await harness.tagSuggestions.suggest(for: document.path, text: try text(of: document))

        #expect(harness.tagSuggestions.loadState(for: document.path) == .off)
        #expect(suggester.requests.isEmpty)
    }

    @Test("says why when Apple Intelligence cannot run")
    func unavailable() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let suggester = StubTagSuggester(availability: .appleIntelligenceOff)
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: Self.on, tagSuggester: suggester)
        let document = try await openSoil(harness)

        await harness.tagSuggestions.suggest(for: document.path, text: try text(of: document))

        #expect(harness.tagSuggestions.loadState(for: document.path) == .unavailable(.appleIntelligenceOff))
        #expect(suggester.requests.isEmpty)
    }

    @Test("suggests once per Note and gives the model the Note's and the Pack's Tags")
    func suggests() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let suggester = StubTagSuggester(result: .success(["soil", "compost"]))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: Self.on, tagSuggester: suggester)
        let document = try await openSoil(harness)
        let text = try text(of: document)

        await harness.tagSuggestions.suggest(for: document.path, text: text)
        await harness.tagSuggestions.suggest(for: document.path, text: text)

        #expect(harness.tagSuggestions.loadState(for: document.path) == .suggested(["soil", "compost"]))
        #expect(suggester.requests.count == 1)
        #expect(suggester.requests.first?.noteName == "Soil")
        #expect(suggester.requests.first?.packTags.contains("meta") == true)
    }

    @Test("asks again when the user wants new suggestions")
    func resuggest() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let suggester = StubTagSuggester(result: .failure(.failed))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: Self.on, tagSuggester: suggester)
        let document = try await openSoil(harness)
        let text = try text(of: document)

        await harness.tagSuggestions.suggest(for: document.path, text: text)
        #expect(harness.tagSuggestions.loadState(for: document.path) == .failed(.failed))

        suggester.result = .success(["soil"])
        await harness.tagSuggestions.resuggest(for: document.path, text: text)

        #expect(harness.tagSuggestions.loadState(for: document.path) == .suggested(["soil"]))
    }

    @Test("a Note too short to tag asks no model")
    func tooShort() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        try pack.write("# Seeds\n\nBuy more.\n", to: "Seeds.md")
        let suggester = StubTagSuggester(result: .success(["seeds"]))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: Self.on, tagSuggester: suggester)
        await harness.openPackWithLinks()

        await harness.tagSuggestions.suggest(for: NotePath("Seeds.md"), text: "# Seeds\n\nBuy more.\n")

        #expect(harness.tagSuggestions.loadState(for: NotePath("Seeds.md")) == .tooShort)
        #expect(suggester.requests.isEmpty)
    }

    @Test("accepting a suggestion adds it to the tags Property and removes it from the line")
    func accept() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let suggester = StubTagSuggester(result: .success(["soil", "compost"]))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: Self.on, tagSuggester: suggester)
        let document = try await openSoil(harness)
        let before = try text(of: document)
        await harness.tagSuggestions.suggest(for: document.path, text: before)

        harness.tagSuggestions.accept("soil", in: document)
        await harness.notes.flush()

        #expect(harness.tagSuggestions.loadState(for: document.path) == .suggested(["compost"]))
        #expect(try pack.text("Soil.md") == before.replacingOccurrences(of: "tags: [garden]\n", with: "tags:\n  - garden\n  - soil\n"))
    }

    @Test("accepting a suggestion for a Note with no frontmatter adds a tags Property and leaves the body alone")
    func acceptWithoutFrontmatter() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let body = "# Seeds\n\nSave seeds from the best tomatoes each summer, dry them on paper and keep them somewhere cool.\n"
        try pack.write(body, to: "Seeds.md")
        let suggester = StubTagSuggester(result: .success(["seeds"]))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: Self.on, tagSuggester: suggester)
        await harness.openPackWithLinks()
        await harness.navigation.open(NotePath("Seeds.md"))
        await harness.links.waitForOpenNote()
        let document = try #require(harness.notes.focused)
        await harness.tagSuggestions.suggest(for: document.path, text: body)

        harness.tagSuggestions.accept("seeds", in: document)
        await harness.notes.flush()

        #expect(try pack.text("Seeds.md") == "---\ntags:\n  - seeds\n---\n" + body)
    }
}
