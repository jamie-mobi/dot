//
//  BacklinkContext.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct BacklinkContext: Hashable, Sendable {
    // MARK: - Stored

    public let before: String
    public let marked: String
    public let after: String

    // MARK: - Init

    public init(before: String, marked: String, after: String) {
        self.before = before
        self.marked = marked
        self.after = after
    }
}
