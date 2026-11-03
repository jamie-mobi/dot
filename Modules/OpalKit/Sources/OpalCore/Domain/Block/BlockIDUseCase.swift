//
//  BlockIDUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum BlockIDUseCase {
    // MARK: - Constants

    public static let idLength = 6

    private enum Constants {
        static let alphabet = Array("abcdefghijklmnopqrstuvwxyz0123456789")
    }

    private enum Pattern {
        static var existingID: Regex<Substring> { /(?:^|\s)\^[A-Za-z0-9-]+[ \t]*$/ }
        static var listItem: Regex<Substring> { /^\s*(?:[-*+]|\d+[.)])\s+/ }
        static var listMarker: Regex<Substring> { /^\s*(?:[-*+]|\d+[.)])\s+(?:\[.\]\s+)?/ }
        static var rule: Regex<Substring> { /^\s*(?:-{3,}|\*{3,}|_{3,})\s*$/ }
    }

    // MARK: - Candidates

    public static func candidates(in text: String) -> [BlockCandidate] {
        let lines = MarkdownNoteParser.splitLines(text)
        var candidates: [BlockCandidate] = []
        var paragraph: (first: String, last: Int, hasID: Bool)?
        var openFence: String?

        func close() {
            if let current = paragraph, current.hasID == false {
                candidates.append(BlockCandidate(line: current.last, text: current.first))
            }
            paragraph = nil
        }

        for line in lines.dropFirst(MarkdownNoteParser.frontmatterLineCount(lines)) {
            let trimmed = line.text.trimmingCharacters(in: .whitespaces)
            if let fence = openFence {
                if trimmed.hasPrefix(fence) {
                    openFence = nil
                }
                continue
            }

            if let fence = MarkdownNoteParser.fenceMarker(trimmed) {
                close()
                openFence = fence
                continue
            }

            guard trimmed.isEmpty == false, trimmed.hasPrefix("#") == false, trimmed.hasPrefix("|") == false, trimmed.wholeMatch(of: Pattern.rule) == nil else {
                close()
                continue
            }

            let hasID = line.text.firstMatch(of: Pattern.existingID) != nil
            let isListItem = line.text.firstMatch(of: Pattern.listItem) != nil
            if isListItem {
                close()
            }

            if let current = paragraph {
                paragraph = (current.first, line.index, current.hasID || hasID)
            } else {
                paragraph = (shown(line.text), line.index, hasID)
            }

            if isListItem {
                close()
            }
        }
        close()
        return candidates.filter { $0.text.isEmpty == false }
    }

    // MARK: - New id

    public static func newID(avoiding existing: Set<String>, using generator: inout some RandomNumberGenerator) -> String {
        while true {
            let id = String((0 ..< idLength).map { _ in Constants.alphabet[Int.random(in: 0 ..< Constants.alphabet.count, using: &generator)] })
            if existing.contains(id) == false {
                return id
            }
        }
    }

    // MARK: - Adding

    public static func adding(_ id: String, toLine line: Int, in text: String) -> String? {
        var lines = text.unicodeScalars.split(separator: "\n", omittingEmptySubsequences: false).map { String(String.UnicodeScalarView($0)) }
        guard lines.indices.contains(line) else {
            return nil
        }

        var target = lines[line]
        let ending = target.unicodeScalars.last == "\r" ? "\r" : ""
        if ending.isEmpty == false {
            target = String(String.UnicodeScalarView(target.unicodeScalars.dropLast()))
        }
        let trimmed = String(target.reversed().drop { $0 == " " || $0 == "\t" }.reversed())
        guard trimmed.isEmpty == false, trimmed.firstMatch(of: Pattern.existingID) == nil else {
            return nil
        }

        lines[line] = trimmed + " ^" + id + ending
        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private static func shown(_ line: String) -> String {
        NotePreviewUseCase.plainText(of: line.replacing(Pattern.listMarker, with: "")).trimmingCharacters(in: .whitespaces)
    }
}
