//
//  StubTagSuggester.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
@testable import DotCore

final class StubTagSuggester: TagSuggesting, @unchecked Sendable {
    // MARK: - Stored

    var availability: TagSuggestionAvailability
    var result: Result<[String], TagSuggestionError>
    private(set) var requests: [TagSuggestionRequest] = []

    // MARK: - Init

    init(availability: TagSuggestionAvailability = .available, result: Result<[String], TagSuggestionError> = .success([])) {
        self.availability = availability
        self.result = result
    }

    // MARK: - TagSuggesting

    func suggestTags(for request: TagSuggestionRequest) async throws(TagSuggestionError) -> [String] {
        requests.append(request)
        return try result.get()
    }
}
