//
//  TagSuggestionRequest.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

public struct TagSuggestionRequest: Hashable, Sendable {
    // MARK: - Stored

    public let noteName: String
    public let body: String
    public let existingTags: [String]
    public let packTags: [String]

    // MARK: - Init

    public init(noteName: String, body: String, existingTags: [String], packTags: [String]) {
        self.noteName = noteName
        self.body = body
        self.existingTags = existingTags
        self.packTags = packTags
    }
}
