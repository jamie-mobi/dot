//
//  BacklinkGroupUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Testing
@testable import OpalCore

@Suite("BacklinkGroupUseCase", .tags(.domain))
struct BacklinkGroupUseCaseTests {
    // MARK: - Fixtures

    private static func backlink(_ source: String, line: Int, text: String = "  See [[Soil]]. ") -> Backlink {
        Backlink(
            source: NotePath(source),
            link: Link(target: "Soil", span: TextSpan(location: line * 10, length: 8), line: line, lineText: text)
        )
    }

    // MARK: - Tests

    @Test("groups Backlinks by Note and keeps their order")
    func groups() {
        let groups = BacklinkGroupUseCase.groups([
            Self.backlink("A.md", line: 1),
            Self.backlink("A.md", line: 4),
            Self.backlink("B.md", line: 2)
        ])

        #expect(groups.map(\.source.rawValue) == ["A.md", "B.md"])
        #expect(groups.first?.backlinks.map(\.link.line) == [1, 4])
    }

    @Test("shows the line without its outer spaces")
    func context() {
        #expect(BacklinkGroupUseCase.context(of: Self.backlink("A.md", line: 0)) == "See [[Soil]].")
    }

    @Test("marks the Link that points here, shown by its alias, and plains the rest of the line")
    func marked() {
        let backlink = Backlink(
            source: NotePath("Tomatoes.md"),
            link: Link(target: "Soil", displayText: "rich earth", span: TextSpan(location: 0, length: 10), line: 1, lineText: "Grow in [[Sun]] and [[Soil|rich earth]], **now**.")
        )
        #expect(BacklinkGroupUseCase.markedContext(of: backlink) == BacklinkContext(before: "Grow in Sun and ", marked: "rich earth", after: ", now."))
    }

    @Test("a Heading Link reads Note › Heading, and a Markdown Link is found by its file")
    func headingAndMarkdown() {
        let heading = Backlink(
            source: NotePath("Embeds.md"),
            link: Link(target: "Soil", subpath: .heading("Types"), span: TextSpan(location: 0, length: 1), line: 1, lineText: "See [[Soil#Types]].")
        )
        #expect(BacklinkGroupUseCase.markedContext(of: heading) == BacklinkContext(before: "See ", marked: "Soil › Types", after: "."))

        let markdown = Backlink(
            source: NotePath("Areas/Health.md"),
            link: Link(target: "Soil", displayText: "soil", span: TextSpan(location: 0, length: 1), line: 1, lineText: "Good food starts in good [soil](Soil.md).")
        )
        #expect(BacklinkGroupUseCase.markedContext(of: markdown).marked == "soil")
    }

    @Test("two Links to the same Note on one line each mark their own")
    func twoOnOneLine() {
        let text = "See [[Soil]] and [rich earth](Soil.md)."
        let group = BacklinkGroup(source: NotePath("A.md"), backlinks: [
            Backlink(source: NotePath("A.md"), link: Link(target: "Soil", span: TextSpan(location: 4, length: 8), line: 2, lineText: text)),
            Backlink(source: NotePath("A.md"), link: Link(target: "Soil", displayText: "rich earth", span: TextSpan(location: 17, length: 21), line: 2, lineText: text))
        ])
        #expect(BacklinkGroupUseCase.markedContexts(in: group).map(\.marked) == ["Soil", "rich earth"])
        #expect(BacklinkGroupUseCase.markedContexts(in: group).last?.before == "See Soil and ")
    }

    @Test("a line with no Link syntax has nothing marked")
    func nothingToMark() {
        let backlink = Self.backlink("A.md", line: 0, text: "Plain words")
        #expect(BacklinkGroupUseCase.markedContext(of: backlink) == BacklinkContext(before: "Plain words", marked: "", after: ""))
    }
}
