//
//  TagSuggestionService.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Observation
import os

@MainActor
@Observable
public final class TagSuggestionService {
    // MARK: - Types

    public enum LoadState: Hashable, Sendable {
        case off
        case unavailable(TagSuggestionAvailability)
        case waiting
        case tooShort
        case suggesting
        case suggested([String])
        case failed(TagSuggestionError)
    }

    // MARK: - State

    public var availability: TagSuggestionAvailability {
        suggester.availability
    }

    public var isOn: Bool {
        settings.settings.suggestsTags
    }

    // MARK: - Private

    private let suggester: any TagSuggesting
    private let links: LinkService
    private let settings: SettingsService
    private var suggestions: [NotePath: [String]] = [:]
    private var errors: [NotePath: TagSuggestionError] = [:]
    private var tooShort: Set<NotePath> = []
    private var running: Set<NotePath> = []
    @ObservationIgnored private let signposter = OSSignposter(subsystem: "com.jamielesouef.Opal", category: "tags")

    // MARK: - Init

    public init(suggester: any TagSuggesting, links: LinkService, settings: SettingsService) {
        self.suggester = suggester
        self.links = links
        self.settings = settings
    }

    // MARK: - Derived

    public func loadState(for path: NotePath) -> LoadState {
        switch (isOn, availability, running.contains(path), errors[path], suggestions[path], tooShort.contains(path)) {
        case (false, _, _, _, _, _):
            .off
        case (true, .deviceNotEligible, _, _, _, _), (true, .appleIntelligenceOff, _, _, _, _), (true, .modelNotReady, _, _, _, _):
            .unavailable(availability)
        case (true, .available, true, _, _, _):
            .suggesting
        case let (true, .available, false, error?, _, _):
            .failed(error)
        case let (true, .available, false, nil, tags?, _):
            .suggested(TagSuggestionUseCase.visible(tags, existing: links.analysis(of: path)?.parsed.tags ?? []))
        case (true, .available, false, nil, nil, true):
            .tooShort
        case (true, .available, false, nil, nil, false):
            .waiting
        }
    }

    // MARK: - Intent

    public func suggest(for path: NotePath, text: String) async {
        guard isOn, availability == .available, running.contains(path) == false, suggestions[path] == nil, errors[path] == nil else {
            return
        }

        guard let request = TagSuggestionUseCase.request(
            noteName: path.name,
            text: text,
            frontmatter: FrontmatterParser.parse(text),
            existingTags: links.analysis(of: path)?.parsed.tags ?? [],
            packTree: links.map.tags
        ) else {
            tooShort.insert(path)
            return
        }

        tooShort.remove(path)
        running.insert(path)
        defer { running.remove(path) }
        let interval = signposter.beginInterval("Suggest Tags")
        defer { signposter.endInterval("Suggest Tags", interval) }
        do throws(TagSuggestionError) {
            let tags = try await suggester.suggestTags(for: request)
            guard Task.isCancelled == false else {
                return
            }

            suggestions[path] = tags
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            errors[path] = error
        }
    }

    public func resuggest(for path: NotePath, text: String) async {
        suggestions[path] = nil
        errors[path] = nil
        tooShort.remove(path)
        await suggest(for: path, text: text)
    }

    public func accept(_ tag: String, in document: NoteDocument) {
        suggestions[document.path]?.removeAll { $0.lowercased() == tag.lowercased() }
        document.addTag(tag)
    }

    public func forget(_ path: NotePath) {
        suggestions[path] = nil
        errors[path] = nil
        tooShort.remove(path)
    }
}
