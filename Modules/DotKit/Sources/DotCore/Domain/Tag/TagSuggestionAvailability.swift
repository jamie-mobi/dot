//
//  TagSuggestionAvailability.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

public enum TagSuggestionAvailability: Hashable, Sendable {
    case available
    case deviceNotEligible
    case appleIntelligenceOff
    case modelNotReady
}
