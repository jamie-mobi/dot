//
//  BlockIDPlan.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct BlockIDPlan: Hashable, Sendable {
    // MARK: - Stored

    public let path: NotePath
    public let id: String
    public let line: Int
    public let original: String
    public let updated: String

    // MARK: - Init

    public init(path: NotePath, id: String, line: Int, original: String, updated: String) {
        self.path = path
        self.id = id
        self.line = line
        self.original = original
        self.updated = updated
    }
}
