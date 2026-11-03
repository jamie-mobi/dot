//
//  NoteStatsUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum NoteStatsUseCase {
    // MARK: - Constants

    private enum Constants {
        static let createdNames: Set<String> = ["created", "date created", "created at"]
        static let dayFormat = Date.ISO8601FormatStyle().year().month().day()
    }

    // MARK: - Stats

    public static func stats(text: String, links: Int, backlinks: Int, fileCreated: Date?) -> NoteStats {
        NoteStats(words: words(in: text), links: links, backlinks: backlinks, created: createdProperty(in: text) ?? fileCreated)
    }

    public static func words(in text: String) -> Int {
        let body = FrontmatterParser.parse(text).map { frontmatter in
            text.split(separator: "\n", omittingEmptySubsequences: false).dropFirst(frontmatter.endLine).joined(separator: "\n")
        } ?? text
        var count = 0
        body.enumerateSubstrings(in: body.startIndex..., options: [.byWords, .substringNotRequired]) { _, _, _, _ in
            count += 1
        }
        return count
    }

    public static func createdProperty(in text: String) -> Date? {
        let property = PropertyIndexUseCase.properties(in: text).first { Constants.createdNames.contains($0.name.lowercased()) }
        guard let value = property?.items.first else {
            return nil
        }

        return try? Constants.dayFormat.parse(String(value.prefix(10)))
    }
}
