//
//  SearchLine.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public struct SearchLine: Hashable, Sendable {
    // MARK: - Stored

    public let line: Int
    public let text: String
    public let highlights: [TextSpan]
    public let kind: SearchLineKind

    // MARK: - Init

    public init(line: Int, text: String, highlights: [TextSpan], kind: SearchLineKind = .text) {
        self.line = line
        self.text = text
        self.highlights = highlights
        self.kind = kind
    }
}
