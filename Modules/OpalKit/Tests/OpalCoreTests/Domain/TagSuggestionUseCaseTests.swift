//
//  TagSuggestionUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("Tag suggestions: requests, model output and adding a Tag", .tags(.domain))
struct TagSuggestionUseCaseTests {
    // MARK: - Normalising

    @Test(
        "turns what the model wrote into a Tag Obsidian reads",
        arguments: [
            ("#Gardening", "gardening"),
            ("Machine Learning", "machine-learning"),
            ("  project/opal ", "project/opal"),
            ("soil & compost!", "soil--compost"),
            ("café", "café"),
            ("/nested/", "nested"),
            ("2026", nil),
            ("###", nil),
            ("", nil)
        ] as [(String, String?)]
    )
    func normalised(raw: String, expected: String?) {
        #expect(TagSuggestionUseCase.normalized(raw) == expected)
    }

    @Test("drops Tags the Note has, repeats and anything past the limit, and keeps the Vault's spelling")
    func tagsFromOutput() {
        let tags = TagSuggestionUseCase.tags(
            from: ["Meta", "gardening", "#gardening", "Tomatoes", "soil", "compost", "seeds", "water"],
            existing: ["meta"],
            vaultTags: ["Tomatoes"]
        )

        #expect(tags == ["gardening", "Tomatoes", "soil", "compost", "seeds"])
    }

    // MARK: - Request

    @Test("asks only about the body, and not for a Note too short to say what it is about")
    func request() {
        let text = "---\ntags:\n  - meta\n---\n# Soil\n\nSoil is a mix of sand, silt, clay and organic matter that plants grow in.\n"
        let frontmatter = Frontmatter(properties: [], endLine: 4, isReadable: true)
        let tree = [
            TagNode(name: "garden", fullName: "garden", noteCount: 2, children: [TagNode(name: "harvest", fullName: "garden/harvest", noteCount: 5, children: nil)]),
            TagNode(name: "meta", fullName: "meta", noteCount: 2, children: nil)
        ]

        let request = TagSuggestionUseCase.request(noteName: "Soil", text: text, frontmatter: frontmatter, existingTags: ["meta"], vaultTree: tree)

        #expect(request?.body.hasPrefix("# Soil") == true)
        #expect(request?.vaultTags == ["garden/harvest", "garden", "meta"])
        #expect(TagSuggestionUseCase.request(noteName: "Soil", text: "# Soil\n\nShort.", frontmatter: nil, existingTags: [], vaultTree: tree) == nil)
    }

    // MARK: - Shown

    @Test("hides a suggestion once the Note has that Tag")
    func visible() {
        #expect(TagSuggestionUseCase.visible(["soil", "Compost"], existing: ["compost"]) == ["soil"])
    }

    // MARK: - Adding

    @Test("adds a Tag to a list, a text value or an empty value, and never twice")
    func adding() {
        #expect(TagSuggestionUseCase.value(adding: "soil", to: .list(["meta"])) == .list(["meta", "soil"]))
        #expect(TagSuggestionUseCase.value(adding: "soil", to: .text("meta, garden")) == .list(["meta", "garden", "soil"]))
        #expect(TagSuggestionUseCase.value(adding: "soil", to: .text("")) == .list(["soil"]))
        #expect(TagSuggestionUseCase.value(adding: "Soil", to: .list(["soil"])) == nil)
        #expect(TagSuggestionUseCase.value(adding: "soil", to: .unreadable("{ odd")) == nil)
    }
}
