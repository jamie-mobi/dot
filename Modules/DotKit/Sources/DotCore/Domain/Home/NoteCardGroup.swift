//
//  NoteCardGroup.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct NoteCardGroup: Hashable, Identifiable, Sendable {
    // MARK: - Stored

    public let folder: NotePath
    public let noteCount: Int
    public let cards: [NoteCard]

    // MARK: - Identifiable

    public var id: NotePath {
        folder
    }

    // MARK: - Init

    public init(folder: NotePath, noteCount: Int, cards: [NoteCard]) {
        self.folder = folder
        self.noteCount = noteCount
        self.cards = cards
    }
}
