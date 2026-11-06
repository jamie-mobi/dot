//
//  LinkSuggestionUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Testing
@testable import DotCore

@Suite("LinkSuggestionUseCase", .tags(.domain))
struct LinkSuggestionUseCaseTests {
    // MARK: - Fixtures

    private static let paths = [
        "Soil.md", "Areas/Notes.md", "Projects/Notes.md", "Projects/Dot/Dot Roadmap.md", "Attachments/seedlings.png"
    ].map(NotePath.init)

    private static let resolver = LinkResolver(paths: paths, aliases: [NotePath("Soil.md"): ["Dirt"]])

    private static func insertion(_ suggestion: LinkSuggestion, markdown: Bool = false) -> String {
        LinkSuggestionUseCase.insertion(for: suggestion, from: NotePath("Welcome.md"), resolver: resolver, useMarkdownLinks: markdown)
    }

    // MARK: - Query

    @Test("finds the open [[ before the cursor", arguments: [
        ("See [[So", 8, "So", 4),
        ("See [[", 6, "", 4),
        ("a\nb ![[Dot R", 12, "Dot R", 5)
    ])
    func openQuery(text: String, cursor: Int, query: String, bracket: Int) throws {
        let found = try #require(LinkSuggestionUseCase.openQuery(in: text, cursor: cursor))

        #expect(found.text == query)
        #expect(found.bracketLocation == bracket)
        #expect(found.queryLocation == bracket + 2)
    }

    @Test("no query once the Link is closed, has a |, or is on another line", arguments: [
        ("[[Soil]] and", 12),
        ("[[Soil|ri", 9),
        ("[[So\nil", 7),
        ("plain text", 5)
    ])
    func noQuery(text: String, cursor: Int) {
        #expect(LinkSuggestionUseCase.openQuery(in: text, cursor: cursor) == nil)
    }

    // MARK: - Heading queries

    @Test("a # asks for that Note's Headings, and only the Heading text is the query", arguments: [
        ("See [[Soil#", 11, "Soil", ""),
        ("See [[Soil#Wa", 13, "Soil", "Wa"),
        ("See [[#Wa", 9, "", "Wa"),
        ("See [[Soil#Top#Wa", 17, "Soil", "Wa")
    ])
    func headingQuery(text: String, cursor: Int, target: String, query: String) throws {
        let found = try #require(LinkSuggestionUseCase.openQuery(in: text, cursor: cursor))

        #expect(found.scope == .headings(of: target))
        #expect(found.text == query)
        #expect(found.bracketLocation == 4)
        #expect(found.queryLocation == cursor - query.utf16.count)
    }

    @Test("Headings stay in document order and narrow by the fuzzy match")
    func headingSuggestions() {
        let note = ParsedNote(
            links: [],
            headings: [Heading(level: 1, text: "Tools", line: 0), Heading(level: 2, text: "Watering", line: 3), Heading(level: 2, text: "Tomatoes", line: 8)],
            blocks: [],
            aliases: []
        )

        let path = NotePath("Soil.md")
        #expect(LinkSuggestionUseCase.headingSuggestions(for: "", in: note, path: path).map(\.name) == ["Tools", "Watering", "Tomatoes"])
        #expect(LinkSuggestionUseCase.headingSuggestions(for: "to", in: note, path: path) == [
            .heading(path, text: "Tools", level: 1),
            .heading(path, text: "Tomatoes", level: 2)
        ])
        #expect(LinkSuggestionUseCase.headingSuggestions(for: "zzz", in: note, path: path).isEmpty)
    }

    @Test("a Note with no Headings suggests nothing")
    func noHeadings() {
        #expect(LinkSuggestionUseCase.headingSuggestions(for: "", in: .empty, path: nil).isEmpty)
    }

    // MARK: - Heading insertion

    @Test("a Heading inserts with the shortest target, or none for the open Note")
    func insertsHeading() {
        #expect(Self.insertion(.heading(NotePath("Soil.md"), text: "Watering Plan", level: 2)) == "[[Soil#Watering Plan]]")
        #expect(Self.insertion(.heading(NotePath("Projects/Notes.md"), text: "Plan", level: 2)) == "[[Projects/Notes#Plan]]")
        #expect(Self.insertion(.heading(nil, text: "Plan", level: 2)) == "[[#Plan]]")
    }

    @Test("a Markdown Link to a Heading encodes the target and the Heading")
    func insertsHeadingAsMarkdown() {
        #expect(Self.insertion(.heading(NotePath("Soil.md"), text: "Watering Plan", level: 2), markdown: true) == "[Soil > Watering Plan](Soil.md#Watering%20Plan)")
        #expect(Self.insertion(.heading(nil, text: "Watering Plan", level: 2), markdown: true) == "[Watering Plan](#Watering%20Plan)")
    }

    @Test("an alias already typed stays on the inserted Link")
    func keepsTypedAlias() {
        let insertion = LinkSuggestionUseCase.insertion(
            for: .heading(NotePath("Soil.md"), text: "Plan", level: 2),
            from: NotePath("Welcome.md"),
            resolver: Self.resolver,
            useMarkdownLinks: false,
            typedAlias: "the plan"
        )

        #expect(insertion == "[[Soil#Plan|the plan]]")
    }

    @Test("what follows the cursor up to ]] belongs to the Link", arguments: [
        ("[[So", 4, 0, nil as String?),
        ("[[So]]", 4, 2, nil),
        ("[[Soil#Wa|the plan]] and more", 9, 11, "the plan"),
        ("[[So and [[Other]]", 4, 0, nil),
        ("[[So\nnext]]", 4, 0, nil)
    ])
    func tail(text: String, cursor: Int, length: Int, alias: String?) {
        #expect(LinkSuggestionUseCase.tail(in: text, cursor: cursor) == LinkTail(length: length, alias: alias))
    }

    // MARK: - Blocks

    @Test("#^ asks for that Note's Blocks, and only the id is the query", arguments: [
        ("See [[Soil#^", 12, "Soil", ""),
        ("See [[Soil#^com", 15, "Soil", "com"),
        ("See [[#^com", 11, "", "com")
    ])
    func blockQuery(text: String, cursor: Int, target: String, query: String) throws {
        let found = try #require(LinkSuggestionUseCase.openQuery(in: text, cursor: cursor))

        #expect(found.scope == .blocks(of: target))
        #expect(found.text == query)
        #expect(found.queryLocation == cursor - query.utf16.count)
    }

    @Test("a ^ anywhere else asks for nothing", arguments: [
        ("[[So^il", 7), ("[[Soil#Top^x", 12), ("[[Soil#^a^b", 11), ("[[Soil#^a#b", 11)
    ])
    func noBlockQuery(text: String, cursor: Int) {
        #expect(LinkSuggestionUseCase.openQuery(in: text, cursor: cursor) == nil)
    }

    @Test("Blocks match on the id or the text; a line with no ^id is not a Block")
    func blockSuggestions() {
        let note = MarkdownNoteParser.parse("""
        Compost improves every kind. ^compost-rule

        No id on this paragraph.

        - Water at dawn ^dawn

        Keep the soil covered.
        ^mulch
        """)
        let path = NotePath("Soil.md")

        #expect(LinkSuggestionUseCase.blockSuggestions(for: "", in: note, path: path) == [
            .block(path, id: "compost-rule", text: "Compost improves every kind."),
            .block(path, id: "dawn", text: "Water at dawn"),
            .block(path, id: "mulch", text: "Keep the soil covered.")
        ])
        #expect(LinkSuggestionUseCase.blockSuggestions(for: "rule", in: note, path: path).map(\.name) == ["Compost improves every kind."])
        #expect(LinkSuggestionUseCase.blockSuggestions(for: "kind", in: note, path: path).map(\.name) == ["Compost improves every kind."])
    }

    @Test("a Block inserts as #^id, and both forms follow to it")
    func insertsAndFollowsBlock() throws {
        let target = NotePath("Soil.md")
        let source = NotePath("Welcome.md")
        let parsedTarget = ParsedNote(links: [], headings: [], blocks: [Block(id: "compost-rule", line: 7, text: "Compost")], aliases: [])
        let map = LinkMap(paths: [target, source], parsed: [target: parsedTarget, source: .empty])
        let suggestion = LinkSuggestion.block(target, id: "compost-rule", text: "Compost")

        let wiki = LinkSuggestionUseCase.insertion(for: suggestion, from: source, resolver: map.resolver, useMarkdownLinks: false)
        let markdown = LinkSuggestionUseCase.insertion(for: suggestion, from: source, resolver: map.resolver, useMarkdownLinks: true)
        #expect(wiki == "[[Soil#^compost-rule]]")
        #expect(markdown == "[Soil > ^compost-rule](Soil.md#^compost-rule)")
        #expect(Self.insertion(.block(nil, id: "x", text: "")) == "[[#^x]]")

        for inserted in [wiki, markdown] {
            let link = try #require(MarkdownNoteParser.parse("See \(inserted)").links.first)
            #expect(LinkFollowUseCase.destination(for: link, from: source, map: map, settings: .defaults) == .note(target, line: 7))
        }
    }

    // MARK: - Round trip

    @Test("every inserted Heading Link parses and follows to that Heading", arguments: [
        "Watering Plan", "C# and Swift", "A | B", "Array[0] values", "Time: 10:30", "^caret", "100%% done"
    ])
    func followsHeading(heading: String) throws {
        let target = NotePath("Soil.md")
        let source = NotePath("Welcome.md")
        let parsedTarget = ParsedNote(links: [], headings: [Heading(level: 2, text: "Other", line: 0), Heading(level: 2, text: heading, line: 4)], blocks: [], aliases: [])
        let map = LinkMap(paths: [target, source], parsed: [target: parsedTarget, source: .empty])

        for markdown in [false, true] {
            let inserted = LinkSuggestionUseCase.insertion(
                for: .heading(target, text: heading, level: 2),
                from: source,
                resolver: map.resolver,
                useMarkdownLinks: markdown
            )
            let link = try #require(MarkdownNoteParser.parse("See \(inserted)").links.first)
            #expect(LinkFollowUseCase.destination(for: link, from: source, map: map, settings: .defaults) == .note(target, line: 4))
        }
    }

    @Test("a Heading Link inside the open Note follows to that Heading")
    func followsOwnHeading() throws {
        let source = NotePath("Welcome.md")
        let parsedSource = ParsedNote(links: [], headings: [Heading(level: 2, text: "Plan", line: 6)], blocks: [], aliases: [])
        let map = LinkMap(paths: [source], parsed: [source: parsedSource])
        let inserted = LinkSuggestionUseCase.insertion(for: .heading(nil, text: "Plan", level: 2), from: source, resolver: map.resolver, useMarkdownLinks: false)
        let link = try #require(MarkdownNoteParser.parse(inserted).links.first)

        #expect(LinkFollowUseCase.destination(for: link, from: source, map: map, settings: .defaults) == .note(source, line: 6))
    }

    // MARK: - Suggestions

    @Test("suggests Notes, Aliases and Unresolved targets")
    func suggestions() {
        let candidates = [SwitcherCandidate(path: NotePath("Soil.md"), aliases: ["Dirt"]), SwitcherCandidate(path: NotePath("Tomatoes.md"))]

        #expect(LinkSuggestionUseCase.suggestions(for: "dir", candidates: candidates, unresolved: ["Dirt Types"], recent: []) == [
            .note(NotePath("Soil.md"), alias: "Dirt"),
            .unresolved("Dirt Types")
        ])
    }

    // MARK: - Insertion

    @Test("inserts the name when it is unambiguous, else the path")
    func shortestPath() {
        #expect(Self.insertion(.note(NotePath("Projects/Dot/Dot Roadmap.md"), alias: nil)) == "[[Dot Roadmap]]")
        #expect(Self.insertion(.note(NotePath("Projects/Notes.md"), alias: nil)) == "[[Projects/Notes]]")
        #expect(Self.insertion(.note(NotePath("Attachments/seedlings.png"), alias: nil)) == "[[seedlings.png]]")
    }

    @Test("an Alias becomes the display text")
    func alias() {
        #expect(Self.insertion(.note(NotePath("Soil.md"), alias: "Dirt")) == "[[Soil|Dirt]]")
    }

    @Test("an Unresolved target is inserted as written")
    func unresolved() {
        #expect(Self.insertion(.unresolved("Ideas That Do Not Exist Yet")) == "[[Ideas That Do Not Exist Yet]]")
    }

    @Test("Markdown Links when the Pack asks for them, with spaces encoded")
    func markdown() {
        #expect(Self.insertion(.note(NotePath("Projects/Dot/Dot Roadmap.md"), alias: nil), markdown: true) == "[Dot Roadmap](Dot%20Roadmap.md)")
        #expect(Self.insertion(.note(NotePath("Soil.md"), alias: "Dirt"), markdown: true) == "[Dirt](Soil.md)")
    }

    @Test("the Link map lists Unresolved targets once")
    func unresolvedTargets() {
        let map = LinkMap(paths: [NotePath("A.md")], parsed: [
            NotePath("A.md"): MarkdownNoteParser.parse("[[Missing]] [[missing]] [[A]] [[Other]]")
        ])

        #expect(map.unresolvedTargets == ["Missing", "Other"])
    }
}
