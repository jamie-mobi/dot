//
//  NoteCard.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct NoteCard: Hashable, Identifiable, Sendable {
    // MARK: - Stored

    public let path: NotePath
    public let preview: [String]
    public let modified: Date
    public let tag: String?

    // MARK: - Identifiable

    public var id: NotePath {
        path
    }

    // MARK: - Init

    public init(path: NotePath, preview: [String], modified: Date, tag: String?) {
        self.path = path
        self.preview = preview
        self.modified = modified
        self.tag = tag
    }
}
