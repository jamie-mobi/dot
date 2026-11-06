//
//  PackEntry.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public struct PackEntry: Hashable, Sendable {
    // MARK: - Stored

    public let path: NotePath
    public let kind: PackItemKind

    // MARK: - Init

    public init(path: NotePath, kind: PackItemKind) {
        self.path = path
        self.kind = kind
    }

    public init(path: NotePath, isFolder: Bool) {
        self.path = path
        kind = isFolder ? .folder : (path.isNote ? .note : .attachment)
    }
}
