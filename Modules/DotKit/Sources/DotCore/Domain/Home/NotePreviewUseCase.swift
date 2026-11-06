//
//  NotePreviewUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum NotePreviewUseCase {
    // MARK: - Constants

    private enum Constants {
        static let frontmatterFence = "---"
        static let maxLineLength = 160
        static let markdownMarks: Set<Character> = ["#", ">", "-", "*", "+", "[", "!", "_", "=", "~", "`", "^"]
    }

    // MARK: - Preview

    public static func preview(of text: String, title: String, maxLines: Int) -> [String] {
        lines(of: text, title: title, maxLines: maxLines).map(\.text)
    }

    public static func lines(of text: String, title: String, maxLines: Int) -> [NotePreviewLine] {
        var lines: [NotePreviewLine] = []
        var isFirstContent = true
        for raw in bodyLines(of: text) {
            let trimmed = raw.trimmingCharacters(in: .whitespaces)
            guard trimmed.isEmpty == false, isBlockID(trimmed) == false, trimmed.hasPrefix("```") == false, trimmed.hasPrefix("|") == false else {
                continue
            }

            let plain = plainText(of: trimmed)
            if isFirstContent, trimmed.hasPrefix("# "), plain.caseInsensitiveCompare(title) == .orderedSame {
                isFirstContent = false
                continue
            }
            isFirstContent = false
            guard plain.isEmpty == false else {
                continue
            }

            lines.append(NotePreviewLine(text: String(plain.prefix(Constants.maxLineLength)), isBullet: isListItem(trimmed)))
            if lines.count == maxLines {
                break
            }
        }
        return lines
    }

    // MARK: - Private

    private static func bodyLines(of text: String) -> [Substring] {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.first?.trimmingCharacters(in: .whitespaces) == Constants.frontmatterFence,
              let end = lines.dropFirst().firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == Constants.frontmatterFence })
        else {
            return lines
        }

        return Array(lines[(end + 1)...])
    }

    private static func isListItem(_ line: String) -> Bool {
        line.firstMatch(of: /^([-*+]|\d+[.)])\s+/) != nil
    }

    private static func isBlockID(_ line: String) -> Bool {
        line.hasPrefix("^") && line.contains(" ") == false
    }

    static func plainText(of line: String) -> String {
        guard line.contains(where: { Constants.markdownMarks.contains($0) || $0.isNumber }) else {
            return line
        }

        var text = line
        text = text.replacing(/^#{1,6}\s+/, with: "")
        text = text.replacing(/^>\s*(\[![^\]]*\]\s*)?/, with: "")
        text = text.replacing(/^([-*+]|\d+[.)])\s+(\[[ xX]\](\s+|$))?/, with: "")
        text = text.replacing(/!?\[\[([^\]|#]*)(#[^\]|]*)?\|([^\]]*)\]\]/) { String($0.output.3) }
        text = text.replacing(/!?\[\[([^\]|#]*)(#[^\]|]*)?\]\]/) { String($0.output.1) }
        text = text.replacing(/!?\[([^\]]*)\]\([^)]*\)/) { String($0.output.1) }
        text = text.replacing(/(\*\*|__|==|~~)(.+?)\1/) { String($0.output.2) }
        text = text.replacing(/(^|[\s(])[*_](\S[^*_]*?)[*_](?=$|[\s.,;:!?)])/) { String($0.output.1) + String($0.output.2) }
        text = text.replacing(/`([^`]*)`/) { String($0.output.1) }
        text = text.replacing(/\s\^[\w-]+$/, with: "")
        return text.trimmingCharacters(in: .whitespaces)
    }
}
