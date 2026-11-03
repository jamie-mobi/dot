//
//  VaultHome.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct VaultHome: Hashable, Sendable {
    // MARK: - Constants

    public static let empty = VaultHome(noteCount: 0, recent: [], groups: [])

    // MARK: - Stored

    public let noteCount: Int
    public let recent: [NoteCard]
    public let groups: [NoteCardGroup]

    // MARK: - Init

    public init(noteCount: Int, recent: [NoteCard], groups: [NoteCardGroup]) {
        self.noteCount = noteCount
        self.recent = recent
        self.groups = groups
    }
}
