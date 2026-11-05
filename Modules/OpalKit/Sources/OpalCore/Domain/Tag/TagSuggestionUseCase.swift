//
//  TagSuggestionUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation

public enum TagSuggestionUseCase {
    // MARK: - Constants

    public enum Constants {
        public static let maxSuggestions = 5
        public static let maxVaultTags = 60
        public static let maxBodyCharacters = 6000
        public static let minimumWords = 12
        static let tagsKeys: Set<String> = ["tags", "tag"]
        static let separators = CharacterSet(charactersIn: ",").union(.whitespaces)
        static let allowed = CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "_/-"))
        static let trimmed = CharacterSet(charactersIn: "/-_")
    }

    // MARK: - Request

    public static func request(noteName: String, text: String, frontmatter: Frontmatter?, existingTags: [String], vaultTree: [TagNode]) -> TagSuggestionRequest? {
        let body = body(of: text, frontmatter: frontmatter)
        guard isWorthSuggesting(body) else {
            return nil
        }

        return TagSuggestionRequest(
            noteName: noteName,
            body: String(body.prefix(Constants.maxBodyCharacters)),
            existingTags: existingTags,
            vaultTags: vaultTags(from: vaultTree)
        )
    }

    public static func body(of text: String, frontmatter: Frontmatter?) -> String {
        guard let frontmatter else {
            return text
        }

        return text.split(separator: "\n", omittingEmptySubsequences: false)
            .dropFirst(frontmatter.endLine)
            .joined(separator: "\n")
    }

    public static func isWorthSuggesting(_ body: String) -> Bool {
        body.split { $0.isWhitespace || $0.isNewline }.count >= Constants.minimumWords
    }

    public static func vaultTags(from tree: [TagNode]) -> [String] {
        flatten(tree)
            .sorted { $0.noteCount == $1.noteCount ? $0.fullName < $1.fullName : $0.noteCount > $1.noteCount }
            .prefix(Constants.maxVaultTags)
            .map(\.fullName)
    }

    // MARK: - Model output

    public static func tags(from generated: [String], existing: [String], vaultTags: [String]) -> [String] {
        let spelling = Dictionary(vaultTags.map { ($0.lowercased(), $0) }) { first, _ in first }
        var seen = Set(existing.map { $0.lowercased() })
        var result: [String] = []
        for raw in generated {
            guard let tag = normalized(raw) else {
                continue
            }

            let key = tag.lowercased()
            guard seen.insert(key).inserted else {
                continue
            }

            result.append(spelling[key] ?? tag)
            if result.count == Constants.maxSuggestions {
                break
            }
        }
        return result
    }

    public static func normalized(_ raw: String) -> String? {
        let words = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .drop { $0 == "#" }
            .lowercased()
            .split { $0.isWhitespace }
            .joined(separator: "-")
        let kept = String(String.UnicodeScalarView(words.unicodeScalars.filter { Constants.allowed.contains($0) }))
            .trimmingCharacters(in: Constants.trimmed)
        guard kept.isEmpty == false, kept.allSatisfy(\.isNumber) == false else {
            return nil
        }

        return kept
    }

    // MARK: - Shown

    public static func visible(_ suggestions: [String], existing: [String]) -> [String] {
        let taken = Set(existing.map { $0.lowercased() })
        return suggestions.filter { taken.contains($0.lowercased()) == false }
    }

    // MARK: - Adding

    public static func isTagsProperty(_ property: Property) -> Bool {
        Constants.tagsKeys.contains(property.key.lowercased())
    }

    public static func value(adding tag: String, to value: PropertyValue) -> PropertyValue? {
        switch value {
        case let .list(items):
            return appending(tag, to: items)
        case let .text(text):
            return appending(tag, to: text.components(separatedBy: Constants.separators).filter { $0.isEmpty == false })
        case .unreadable:
            return nil
        }
    }

    // MARK: - Private

    private static func appending(_ tag: String, to items: [String]) -> PropertyValue? {
        guard items.contains(where: { $0.lowercased() == tag.lowercased() }) == false else {
            return nil
        }

        return .list(items + [tag])
    }

    private static func flatten(_ nodes: [TagNode]) -> [TagNode] {
        nodes.flatMap { [$0] + flatten($0.children ?? []) }
    }
}
