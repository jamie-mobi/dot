//
//  TagSuggesting.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

public protocol TagSuggesting: Sendable {
    var availability: TagSuggestionAvailability { get }
    func suggestTags(for request: TagSuggestionRequest) async throws(TagSuggestionError) -> [String]
}
