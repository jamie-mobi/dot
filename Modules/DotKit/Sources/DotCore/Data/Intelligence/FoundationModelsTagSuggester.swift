//
//  FoundationModelsTagSuggester.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import FoundationModels

public final class FoundationModelsTagSuggester: TagSuggesting {
    // MARK: - Private

    private let model: SystemLanguageModel

    // MARK: - Init

    public init() {
        model = SystemLanguageModel(useCase: .contentTagging)
    }

    // MARK: - TagSuggesting

    public var availability: TagSuggestionAvailability {
        switch model.availability {
        case .available:
            .available
        case .unavailable(.deviceNotEligible):
            .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            .appleIntelligenceOff
        case .unavailable(.modelNotReady):
            .modelNotReady
        case .unavailable:
            .modelNotReady
        }
    }

    public func suggestTags(for request: TagSuggestionRequest) async throws(TagSuggestionError) -> [String] {
        let availability = availability
        guard availability == .available else {
            throw .unavailable(availability)
        }

        let session = LanguageModelSession(model: model, instructions: TagSuggestionPrompt.instructions)
        do {
            let response = try await session.respond(
                to: TagSuggestionPrompt.prompt(for: request),
                generating: GeneratedTagsDTO.self,
                options: GenerationOptions(samplingMode: .greedy)
            )
            return TagSuggestionUseCase.tags(from: response.content.tags, existing: request.existingTags, packTags: request.packTags)
        } catch {
            throw Self.classify(error)
        }
    }

    // MARK: - Private

    private static func classify(_ error: any Error) -> TagSuggestionError {
        if error is CancellationError {
            return .failed
        }
        if case .exceededContextWindowSize = error as? LanguageModelSession.GenerationError {
            return .noteTooLong
        }
        if error is LanguageModelSession.GenerationError {
            return .declined
        }
        AppLog.error("Suggesting Tags failed: \(error)")
        return .failed
    }
}
