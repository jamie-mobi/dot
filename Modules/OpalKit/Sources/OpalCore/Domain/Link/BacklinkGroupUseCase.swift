//
//  BacklinkGroupUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public enum BacklinkGroupUseCase {
    // MARK: - Groups

    public static func groups(_ backlinks: [Backlink]) -> [BacklinkGroup] {
        var order: [NotePath] = []
        var bySource: [NotePath: [Backlink]] = [:]
        for backlink in backlinks {
            if bySource[backlink.source] == nil {
                order.append(backlink.source)
            }
            bySource[backlink.source, default: []].append(backlink)
        }
        return order.map { BacklinkGroup(source: $0, backlinks: bySource[$0] ?? []) }
    }

    // MARK: - Context

    public static func context(of backlink: Backlink) -> String {
        backlink.link.lineText.trimmingCharacters(in: .whitespaces)
    }

    public static func markedContexts(in group: BacklinkGroup) -> [BacklinkContext] {
        var seen: [Int: Int] = [:]
        return group.backlinks.map { backlink in
            let occurrence = seen[backlink.link.line, default: 0]
            seen[backlink.link.line] = occurrence + 1
            return markedContext(of: backlink, occurrence: occurrence)
        }
    }

    public static func markedContext(of backlink: Backlink, occurrence: Int = 0) -> BacklinkContext {
        let line = context(of: backlink)
        let matches = line.matches(of: /!?\[\[([^\]|#]*)[^\]]*\]\]|!?\[[^\]]*\]\(([^)]*)\)/)
        let wanted = normalized(backlink.link.target)
        let pointing = matches.filter { match in
            let target = match.output.1.map(String.init) ?? match.output.2.map(String.init) ?? ""
            return normalized(target) == wanted
        }
        let match = pointing.indices.contains(occurrence) ? pointing[occurrence] : (pointing.first ?? matches.first)
        guard let match else {
            return BacklinkContext(before: NotePreviewUseCase.plainText(of: line), marked: "", after: "")
        }

        return BacklinkContext(
            before: plain(String(line[..<match.range.lowerBound]), trailing: true),
            marked: ReadingInlineBuilder.display(backlink.link),
            after: plain(String(line[match.range.upperBound...]), trailing: false),
            embed: BacklinkEmbed(backlink.link)
        )
    }

    // MARK: - Private

    private static func normalized(_ target: String) -> String {
        let decoded = target.removingPercentEncoding ?? target
        let name = decoded.split(separator: "/").last.map(String.init) ?? decoded
        let bare = name.split(separator: "#").first.map(String.init) ?? name
        return (bare.lowercased().hasSuffix(".md") ? String(bare.dropLast(3)) : bare).lowercased()
    }

    private static func plain(_ text: String, trailing: Bool) -> String {
        guard text.isEmpty == false else {
            return ""
        }

        let edge = trailing ? text.last : text.first
        let converted = NotePreviewUseCase.plainText(of: text).trimmingCharacters(in: .whitespaces)
        guard edge?.isWhitespace == true else {
            return converted
        }

        return trailing ? converted + " " : " " + converted
    }
}
