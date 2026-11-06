//
//  PackHomeGroup.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct PackHomeGroup: Hashable, Sendable {
    // MARK: - Stored

    public let folder: NotePath
    public let noteCount: Int
    public let notes: [NotePath]

    // MARK: - Init

    public init(folder: NotePath, noteCount: Int, notes: [NotePath]) {
        self.folder = folder
        self.noteCount = noteCount
        self.notes = notes
    }
}
