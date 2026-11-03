//
//  SearchFilterUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Testing
@testable import OpalCore

@Suite("SearchFilterUseCase", .tags(.domain))
struct SearchFilterUseCaseTests {
    // MARK: - Tests

    @Test("choosing a Folder writes the same path: filter as typing it")
    func folder() {
        let chosen = SearchFilterUseCase.setting(folder: "Daily Notes", in: "soil")
        #expect(chosen == "soil path:\"Daily Notes\"")
        #expect(SearchQueryUseCase.parse(chosen) == SearchQueryUseCase.parse("soil path:\"Daily Notes\""))
        #expect(SearchFilterUseCase.folder(in: chosen) == "Daily Notes")
    }

    @Test("choosing a Tag writes the same tag: filter as typing it")
    func tag() {
        let chosen = SearchFilterUseCase.setting(tag: "garden", in: "\"rich soil\" -clay")
        #expect(chosen == "\"rich soil\" -clay tag:#garden")
        #expect(SearchQueryUseCase.parse(chosen) == SearchQueryUseCase.parse("\"rich soil\" -clay tag:#garden"))
        #expect(SearchFilterUseCase.tag(in: chosen) == "garden")
    }

    @Test("a new choice replaces the old one, and None removes it, leaving the rest")
    func replace() {
        let text = "soil path:Areas tag:#garden"
        #expect(SearchFilterUseCase.setting(folder: "Projects", in: text) == "soil tag:#garden path:Projects")
        #expect(SearchFilterUseCase.setting(folder: nil, in: text) == "soil tag:#garden")
        #expect(SearchFilterUseCase.setting(tag: nil, in: text) == "soil path:Areas")
    }

    @Test("Search lines say whether they come from text, a quote or a Property")
    func lineKinds() {
        let text = "---\nsource: The Soil Book\n---\nSoil first.\n> Soil is alive.\n"
        let result = SearchSnippetUseCase.result(for: NotePath("A.md"), text: text, query: SearchQueryUseCase.parse("soil"))
        #expect(result.lines.map(\.kind) == [.property, .text, .quote])
    }
}
