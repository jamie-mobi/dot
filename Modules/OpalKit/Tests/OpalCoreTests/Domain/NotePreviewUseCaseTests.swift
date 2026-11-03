//
//  NotePreviewUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Testing
@testable import OpalCore

@Suite("NotePreviewUseCase", .tags(.domain))
struct NotePreviewUseCaseTests {
    // MARK: - Tests

    @Test("skips the frontmatter and a first Heading that repeats the Note's name")
    func skipsFrontmatterAndTitle() {
        let text = "---\ntags: [garden]\n---\n# Soil\n\nSoil is a mix of sand.\n"
        #expect(NotePreviewUseCase.preview(of: text, title: "Soil", maxLines: 4) == ["Soil is a mix of sand."])
    }

    @Test("keeps a first Heading that differs from the name, without its marks")
    func keepsOtherHeading() {
        #expect(NotePreviewUseCase.preview(of: "## Planting\nDig.", title: "Tomatoes", maxLines: 4) == ["Planting", "Dig."])
    }

    @Test("hides Markdown: Links by alias or name, emphasis, code, list and task marks")
    func hidesMarkdown() {
        let text = "Grow in [[Soil|rich earth]], see [[Soil#^compost-rule]].\n- [ ] Order **more** stakes\n- Read `ch 3` and *slowly*\n> [!note] Rain due\nRead [the book](Book.md)."
        #expect(NotePreviewUseCase.preview(of: text, title: "X", maxLines: 5) == [
            "Grow in rich earth, see Soil.",
            "Order more stakes",
            "Read ch 3 and slowly",
            "Rain due",
            "Read the book."
        ])
    }

    @Test("drops Block ids, empty tasks, table rows, code fences and blank lines, and stops at the limit")
    func dropsNoise() {
        let text = "One ^a1\n\n^b2\n- [ ]\n| A | B |\n```swift\nTwo\nThree\nFour"
        #expect(NotePreviewUseCase.preview(of: text, title: "X", maxLines: 3) == ["One", "Two", "Three"])
    }

    @Test("an empty Note has no preview")
    func empty() {
        #expect(NotePreviewUseCase.preview(of: "", title: "X", maxLines: 4).isEmpty)
        #expect(NotePreviewUseCase.preview(of: "---\na: 1\n---\n", title: "X", maxLines: 4).isEmpty)
    }
}
