//
//  PackTreeNode.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public struct PackTreeNode: Identifiable, Hashable, Sendable {
    // MARK: - Stored

    public let path: NotePath
    public let kind: PackItemKind
    public let children: [PackTreeNode]?

    // MARK: - Init

    public init(path: NotePath, kind: PackItemKind, children: [PackTreeNode]?) {
        self.path = path
        self.kind = kind
        self.children = children
    }

    // MARK: - Identifiable

    public var id: NotePath {
        path
    }

    // MARK: - Derived

    public var displayName: String {
        switch kind {
        case .note:
            path.name
        case .folder,
             .attachment:
            path.fileName
        }
    }
}
