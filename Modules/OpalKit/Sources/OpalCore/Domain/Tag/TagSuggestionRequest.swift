//
//  TagSuggestionRequest.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

public struct TagSuggestionRequest: Hashable, Sendable {
    // MARK: - Stored

    public let noteName: String
    public let body: String
    public let existingTags: [String]
    public let vaultTags: [String]

    // MARK: - Init

    public init(noteName: String, body: String, existingTags: [String], vaultTags: [String]) {
        self.noteName = noteName
        self.body = body
        self.existingTags = existingTags
        self.vaultTags = vaultTags
    }
}
