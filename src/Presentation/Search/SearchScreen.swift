//
//  SearchScreen.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct SearchScreen: View {
    // MARK: - Environment

    @Environment(\.searchService) private var search
    @Environment(\.vaultService) private var vault
    @Environment(\.folderColourService) private var folderColours

    // MARK: - Input

    let vaultName: String

    // MARK: - State

    @State private var selectedLine: SearchLineID?

    // MARK: - View

    var body: some View {
        @Bindable var search = search
        VStack(alignment: .leading, spacing: AppSpacing.comfortable) {
            SearchFieldView(query: $search.query, focusRequest: search.focusRequest, onMove: move, onSubmit: openSelected)
            SearchFilterBar(summary: summary)
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(AppSpacing.large)
        .onChange(of: results) { _, results in
            selectedLine = lineIDs(in: results).first
        }
        .onAppear {
            selectedLine = lineIDs(in: results).first
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch search.loadState {
        case .idle:
            ContentUnavailableView(
                String(localized: "Search the Vault"),
                systemImage: "magnifyingglass",
                description: Text(String(localized: "Use \"quotes\" for a phrase, -word to exclude, and path:, file: or tag:#name to narrow."))
            )
        case .searching where results.isEmpty:
            ProgressView()
                .controlSize(.small)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.large)
        case .unavailable:
            ContentUnavailableView(
                String(localized: "Search Is Not Ready"),
                systemImage: "hourglass",
                description: Text(String(localized: "Opal is still reading the Vault."))
            )
        case .results where results.isEmpty:
            ContentUnavailableView.search(text: search.query)
        case .searching,
             .results:
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppSpacing.comfortable) {
                        ForEach(results) { result in
                            SearchResultGroupView(
                                result: result,
                                terms: terms,
                                location: location(of: result.path),
                                colour: folderColours.colour(for: result.path)?.color ?? AppLabelColor.neutral,
                                selectedLine: selectedLine
                            ) { line in
                                open(result, line: line)
                            }
                        }
                    }
                    .padding(AppSpacing.tiny)
                }
                .onChange(of: selectedLine) { _, line in
                    if let line {
                        proxy.scrollTo(line)
                    }
                }
            }
        }
    }

    // MARK: - Derived

    private var results: [SearchResult] {
        if case let .results(results) = search.loadState {
            return results
        }
        return []
    }

    private var terms: [String] {
        search.query
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
            .filter { $0.isEmpty == false && $0.hasPrefix("-") == false && $0.contains(":") == false }
    }

    private var summary: String {
        guard case let .results(results) = search.loadState, results.isEmpty == false else {
            return ""
        }

        let matches = results.reduce(0) { $0 + $1.matchCount }
        let matchText = matches == 1 ? String(localized: "1 match") : String(localized: "\(matches) matches")
        let noteText = results.count == 1 ? String(localized: "1 Note") : String(localized: "\(results.count) Notes")
        let order = SearchQueryUseCase.parse(search.query).hasTextTerms ? String(localized: "Sorted by relevance") : String(localized: "Sorted by name")
        return String(localized: "\(matchText) in \(noteText) · \(order)")
    }

    private func location(of path: NotePath) -> String {
        path.parent.isRoot ? vaultName : path.parent.rawValue
    }

    private func lineIDs(in results: [SearchResult]) -> [SearchLineID] {
        results.flatMap { result in result.lines.map { SearchLineID(path: result.path, line: $0.line) } }
    }

    // MARK: - Actions

    private func move(_ delta: Int) {
        let ids = lineIDs(in: results)
        guard ids.isEmpty == false else {
            return
        }

        let current = selectedLine.flatMap { ids.firstIndex(of: $0) } ?? -1
        selectedLine = ids[min(max(current + delta, 0), ids.count - 1)]
    }

    private func openSelected() {
        guard let selectedLine, let result = results.first(where: { $0.path == selectedLine.path }) else {
            return
        }

        open(result, line: selectedLine.line)
    }

    private func open(_ result: SearchResult, line: Int?) {
        Usage.log("search_result_opened")
        Task { await search.open(result, line: line) }
    }
}
