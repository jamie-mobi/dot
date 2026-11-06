//
//  LinkSuggestionUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public enum LinkSuggestionUseCase {
    // MARK: - Constants

    public static let limit = 30

    private enum Constants {
        static let opener = "[["
        static let closer = "]]"
        static let stoppers: [Character] = ["|", "]", "\n"]
        static let subpathMark: Character = "#"
        static let blockMark: Character = "^"
        static let noteSuffix = ".\(NotePath.noteExtension)"
    }

    // MARK: - Query

    public static func openQuery(in text: String, cursor: Int) -> LinkQuery? {
        let nsText = text as NSString
        guard cursor >= 0, cursor <= nsText.length else {
            return nil
        }

        let lineStart = nsText.lineRange(for: NSRange(location: cursor, length: 0)).location
        let before = nsText.substring(with: NSRange(location: lineStart, length: cursor - lineStart)) as NSString
        let opener = before.range(of: Constants.opener, options: .backwards)
        guard opener.location != NSNotFound else {
            return nil
        }

        let query = before.substring(from: opener.location + opener.length)
        guard query.contains(where: Constants.stoppers.contains) == false, query.hasPrefix(" ") == false else {
            return nil
        }

        let bracket = lineStart + opener.location
        guard let hash = query.firstIndex(of: Constants.subpathMark), let last = query.lastIndex(of: Constants.subpathMark) else {
            guard query.contains(Constants.blockMark) == false else {
                return nil
            }
            return LinkQuery(bracketLocation: bracket, queryLocation: bracket + opener.length, text: query)
        }

        let target = String(query[..<hash])
        let subpath = query[query.index(after: hash)...]
        guard target.contains(Constants.blockMark) == false else {
            return nil
        }

        if subpath.first == Constants.blockMark {
            let id = String(subpath.dropFirst())
            guard id.contains(Constants.blockMark) == false, id.contains(Constants.subpathMark) == false else {
                return nil
            }
            return LinkQuery(bracketLocation: bracket, queryLocation: cursor - id.utf16.count, text: id, scope: .blocks(of: target))
        }

        let heading = String(query[query.index(after: last)...])
        guard subpath.contains(Constants.blockMark) == false else {
            return nil
        }

        return LinkQuery(
            bracketLocation: bracket,
            queryLocation: cursor - heading.utf16.count,
            text: heading,
            scope: .headings(of: target)
        )
    }

    public static func tail(in text: String, cursor: Int) -> LinkTail {
        let nsText = text as NSString
        guard cursor >= 0, cursor <= nsText.length else {
            return LinkTail(length: 0, alias: nil)
        }

        let line = nsText.lineRange(for: NSRange(location: cursor, length: 0))
        let rest = nsText.substring(with: NSRange(location: cursor, length: NSMaxRange(line) - cursor)) as NSString
        let closer = rest.range(of: Constants.closer)
        guard closer.location != NSNotFound else {
            return LinkTail(length: 0, alias: nil)
        }

        let inside = rest.substring(to: closer.location) as NSString
        guard inside.range(of: Constants.opener).location == NSNotFound else {
            return LinkTail(length: 0, alias: nil)
        }

        let bar = inside.range(of: "|")
        let alias = bar.location == NSNotFound ? "" : inside.substring(from: NSMaxRange(bar))
        return LinkTail(length: NSMaxRange(closer), alias: alias.isEmpty ? nil : alias)
    }

    // MARK: - Suggestions

    public static func suggestions(
        for query: String,
        candidates: [SwitcherCandidate],
        unresolved: [String],
        recent: [NotePath],
        limit: Int = limit
    ) -> [LinkSuggestion] {
        let notes = QuickSwitcherMatchUseCase.matches(query: query, candidates: candidates, recent: recent, limit: limit)
            .map { LinkSuggestion.note($0.path, alias: $0.matchedAlias) }
        let needle = Array(query.lowercased().filter { $0.isWhitespace == false })
        let missing = unresolved
            .compactMap { name in QuickSwitcherMatchUseCase.fuzzyScore(needle, in: name).map { (name, $0) } }
            .sorted { $0.1 > $1.1 }
            .map { LinkSuggestion.unresolved($0.0) }
        return Array((notes + missing).prefix(limit))
    }

    public static func headingSuggestions(
        for query: String,
        in note: ParsedNote,
        path: NotePath?,
        limit: Int = limit
    ) -> [LinkSuggestion] {
        let needle = Array(query.lowercased().filter { $0.isWhitespace == false })
        let found = note.headings
            .filter { linkText(forHeading: $0.text).isEmpty == false }
            .filter { needle.isEmpty || QuickSwitcherMatchUseCase.fuzzyScore(needle, in: $0.text) != nil }
            .map { LinkSuggestion.heading(path, text: $0.text, level: $0.level) }
        return Array(found.prefix(limit))
    }

    public static func blockSuggestions(
        for query: String,
        in note: ParsedNote,
        path: NotePath?,
        limit: Int = limit
    ) -> [LinkSuggestion] {
        let needle = Array(query.lowercased().filter { $0.isWhitespace == false })
        let found = note.blocks
            .filter { block in
                needle.isEmpty
                    || QuickSwitcherMatchUseCase.fuzzyScore(needle, in: block.id) != nil
                    || QuickSwitcherMatchUseCase.fuzzyScore(needle, in: block.text) != nil
            }
            .map { LinkSuggestion.block(path, id: $0.id, text: $0.text) }
        return Array(found.prefix(limit))
    }

    public static func newBlockSuggestions(
        for query: String,
        in candidates: [BlockCandidate],
        path: NotePath,
        limit: Int = limit
    ) -> [LinkSuggestion] {
        let needle = Array(query.lowercased().filter { $0.isWhitespace == false })
        let found = candidates
            .filter { needle.isEmpty || QuickSwitcherMatchUseCase.fuzzyScore(needle, in: $0.text) != nil }
            .map { LinkSuggestion.newBlock(path, line: $0.line, text: $0.text) }
        return Array(found.prefix(limit))
    }

    // MARK: - Insertion

    public static func insertion(
        for suggestion: LinkSuggestion,
        from source: NotePath,
        resolver: LinkResolver,
        useMarkdownLinks: Bool,
        typedAlias: String? = nil
    ) -> String {
        switch suggestion {
        case let .note(path, alias):
            let target = shortestTarget(for: path, from: source, resolver: resolver)
            let shown = typedAlias ?? alias
            guard useMarkdownLinks else {
                return wikilink(target, alias: shown)
            }
            return markdownLink(text: shown ?? path.name, target: path.isNote ? target + Constants.noteSuffix : target)
        case let .unresolved(name):
            guard useMarkdownLinks else {
                return wikilink(name, alias: typedAlias)
            }
            return markdownLink(text: typedAlias ?? name, target: name + Constants.noteSuffix)
        case let .heading(path, text, _):
            let heading = linkText(forHeading: text)
            let target = path.map { shortestTarget(for: $0, from: source, resolver: resolver) } ?? ""
            guard useMarkdownLinks else {
                return wikilink(target + String(Constants.subpathMark) + heading, alias: typedAlias)
            }
            let shown = typedAlias ?? path.map { "\($0.name) > \(heading)" } ?? heading
            return markdownLink(
                text: shown,
                target: path == nil ? "" : target + Constants.noteSuffix,
                fragment: encoded(heading)
            )
        case let .block(path, id, _):
            let subpath = String(Constants.blockMark) + id
            let target = path.map { shortestTarget(for: $0, from: source, resolver: resolver) } ?? ""
            guard useMarkdownLinks else {
                return wikilink(target + String(Constants.subpathMark) + subpath, alias: typedAlias)
            }
            let shown = typedAlias ?? path.map { "\($0.name) > \(subpath)" } ?? subpath
            return markdownLink(text: shown, target: path == nil ? "" : target + Constants.noteSuffix, fragment: subpath)
        case let .newBlock(path, _, _):
            return insertion(for: .note(path, alias: nil), from: source, resolver: resolver, useMarkdownLinks: useMarkdownLinks, typedAlias: typedAlias)
        }
    }

    public static func linkText(forHeading heading: String) -> String {
        heading
            .replacing(/[:#|^\\\[\]]|%%/, with: " ")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    public static func shortestTarget(for path: NotePath, from source: NotePath, resolver: LinkResolver) -> String {
        let name = path.isNote ? path.name : path.fileName
        if resolver.resolve(name, from: source) == path {
            return name
        }

        let raw = path.rawValue
        return path.isNote ? String(raw.dropLast(Constants.noteSuffix.count)) : raw
    }

    // MARK: - Private

    private static func wikilink(_ target: String, alias: String?) -> String {
        Constants.opener + target + (alias.map { "|\($0)" } ?? "") + Constants.closer
    }

    private static func markdownLink(text: String, target: String, fragment: String? = nil) -> String {
        "[\(text)](\(encoded(target))\(fragment.map { "#\($0)" } ?? ""))"
    }

    private static func encoded(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(CharacterSet(charactersIn: "()"))) ?? text
    }
}
