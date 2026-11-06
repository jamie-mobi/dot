//
//  TagSuggestionError.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

public enum TagSuggestionError: Error, Hashable, Sendable {
    case unavailable(TagSuggestionAvailability)
    case noteTooLong
    case declined
    case failed
}
