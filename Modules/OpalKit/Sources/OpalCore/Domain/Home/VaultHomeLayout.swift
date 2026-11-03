//
//  VaultHomeLayout.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct VaultHomeLayout: Hashable, Sendable {
    // MARK: - Constants

    public static let empty = VaultHomeLayout(noteCount: 0, recent: [], groups: [])

    // MARK: - Stored

    public let noteCount: Int
    public let recent: [NotePath]
    public let groups: [VaultHomeGroup]

    // MARK: - Derived

    public var shownNotes: [NotePath] {
        var seen = Set<NotePath>()
        return (recent + groups.flatMap(\.notes)).filter { seen.insert($0).inserted }
    }

    // MARK: - Init

    public init(noteCount: Int, recent: [NotePath], groups: [VaultHomeGroup]) {
        self.noteCount = noteCount
        self.recent = recent
        self.groups = groups
    }
}
