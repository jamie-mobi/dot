//
//  SearchView.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct SearchView: View {
    // MARK: - Environment

    @Environment(\.searchService) private var search
    @Environment(\.vaultService) private var vault
    @Environment(\.linkService) private var links

    // MARK: - State

    @FocusState private var isQueryFocused: Bool

    // MARK: - View

    var body: some View {
        @Bindable var search = search
        VStack(spacing: 0) {
            TextField(String(localized: "Search"), text: $search.query, prompt: Text(String(localized: "Search the Vault")))
                .textFieldStyle(.roundedBorder)
                .focused($isQueryFocused)
                .padding(.horizontal, AppSpacing.small)
                .padding(.bottom, AppSpacing.small)
                .help(String(localized: "Words, \"phrases\", -exclude, path:, file:, tag:#name"))

            filters
                .padding(.horizontal, AppSpacing.small)
                .padding(.bottom, AppSpacing.small)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            isQueryFocused = true
        }
        .onChange(of: search.focusRequest) {
            isQueryFocused = true
        }
    }

    // MARK: - Filters

    private var filters: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.small) {
                folderPicker
                tagPicker
            }
            .labelsHidden()
            HStack(spacing: AppSpacing.small) {
                scopePicker
                    .labelsHidden()
                Toggle(String(localized: "Match Case"), isOn: Binding {
                    search.options.matchesCase
                } set: {
                    search.options.matchesCase = $0
                })
                .toggleStyle(.checkbox)
                .fixedSize()
                .help(String(localized: "Show only matches with the same capital and small letters"))
            }
        }
        .controlSize(.small)
    }

    private var scopePicker: some View {
        Picker(String(localized: "Where"), selection: Binding {
            search.options.scope
        } set: {
            search.options.scope = $0
        }) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.title).tag(scope)
            }
        }
    }

    private var folderPicker: some View {
        Picker(String(localized: "Folder"), selection: Binding {
            SearchFilterUseCase.folder(in: search.query)
        } set: {
            search.query = SearchFilterUseCase.setting(folder: $0, in: search.query)
        }) {
            Text(String(localized: "All Folders")).tag(String?.none)
            Divider()
            ForEach(topFolders, id: \.self) { folder in
                Text(folder).tag(Optional(folder))
            }
        }
    }

    private var tagPicker: some View {
        Picker(String(localized: "Tag"), selection: Binding {
            SearchFilterUseCase.tag(in: search.query)
        } set: {
            search.query = SearchFilterUseCase.setting(tag: $0, in: search.query)
        }) {
            Text(String(localized: "Any Tag")).tag(String?.none)
            Divider()
            ForEach(topTags, id: \.self) { tag in
                Text("#\(tag)").tag(Optional(tag))
            }
        }
    }

    private var topFolders: [String] {
        vault.tree.filter { $0.kind == .folder }.map(\.path.rawValue)
    }

    private var topTags: [String] {
        links.map.tags.map(\.name)
    }

    private func summary(_ results: [SearchResult]) -> String {
        let matches = results.reduce(0) { $0 + $1.matchCount }
        let matchText = matches == 1 ? String(localized: "1 match") : String(localized: "\(matches) matches")
        let noteText = results.count == 1 ? String(localized: "1 Note") : String(localized: "\(results.count) Notes")
        return String(localized: "\(matchText) in \(noteText)")
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
        case .searching:
            ProgressView()
                .controlSize(.small)
                .padding()
        case .unavailable:
            ContentUnavailableView(
                String(localized: "Search Is Not Ready"),
                systemImage: "hourglass",
                description: Text(String(localized: "Opal is still reading the Vault."))
            )
        case let .results(results) where results.isEmpty:
            ContentUnavailableView.search(text: search.query)
        case let .results(results):
            List {
                Text(summary(results))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                ForEach(results) { result in
                    Section {
                        ForEach(result.lines, id: \.line) { line in
                            Button {
                                Usage.log("search_result_opened")
                                Task { await search.open(result, line: line.line) }
                            } label: {
                                VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                                    Text(line.kind.title)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                    Text(SearchLineText.attributed(line))
                                        .font(.callout)
                                        .lineLimit(3)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Button {
                            Usage.log("search_result_opened")
                            Task { await search.open(result, line: nil) }
                        } label: {
                            HStack {
                                Label(result.path.name, systemImage: "text.document")
                                    .lineLimit(1)
                                Spacer()
                                Text(result.matchCount, format: .number)
                                    .monospacedDigit()
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.trailing, AppSpacing.small)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.sidebar)
        }
    }
}
