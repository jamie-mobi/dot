//
//  NoteCard.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct NoteCard: Hashable, Identifiable, Sendable {
    // MARK: - Stored

    public let path: NotePath
    public let lines: [NotePreviewLine]
    public let modified: Date
    public let tag: String?

    // MARK: - Identifiable

    public var id: NotePath {
        path
    }

    // MARK: - Derived

    public var preview: [String] {
        lines.map(\.text)
    }

    // MARK: - Init

    public init(path: NotePath, lines: [NotePreviewLine], modified: Date, tag: String?) {
        self.path = path
        self.lines = lines
        self.modified = modified
        self.tag = tag
    }
}
