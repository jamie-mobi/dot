//
//  BacklinkContext.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct BacklinkContext: Hashable, Sendable {
    // MARK: - Stored

    public let before: String
    public let marked: String
    public let after: String
    public let embed: BacklinkEmbed?

    // MARK: - Init

    public init(before: String, marked: String, after: String, embed: BacklinkEmbed? = nil) {
        self.before = before
        self.marked = marked
        self.after = after
        self.embed = embed
    }
}
