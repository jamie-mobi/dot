//
//  NoteStats.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct NoteStats: Hashable, Sendable {
    // MARK: - Stored

    public let words: Int
    public let links: Int
    public let backlinks: Int
    public let created: Date?

    // MARK: - Init

    public init(words: Int, links: Int, backlinks: Int, created: Date?) {
        self.words = words
        self.links = links
        self.backlinks = backlinks
        self.created = created
    }
}
