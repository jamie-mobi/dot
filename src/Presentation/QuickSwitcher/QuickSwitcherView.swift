//
//  QuickSwitcherView.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct QuickSwitcherView: View {
    // MARK: - Environment

    @Environment(\.quickSwitcherService) private var switcher
    @Environment(\.navigationService) private var navigation
    @Environment(\.linkService) private var links
    @Environment(\.vaultService) private var vault

    // MARK: - State

    @FocusState private var isQueryFocused: Bool

    // MARK: - View

    var body: some View {
        @Bindable var switcher = switcher
        VStack(spacing: 0) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(String(localized: "Find or create a Note"), text: $switcher.query)
                    .textFieldStyle(.plain)
                    .focused($isQueryFocused)
            }
            .font(.title3)
            .padding(AppSpacing.regular)
            .onKeyPress(.downArrow) {
                switcher.moveSelection(by: 1)
                return .handled
            }
            .onKeyPress(.upArrow) {
                switcher.moveSelection(by: -1)
                return .handled
            }
            .onKeyPress(.return, phases: .down) { press in
                guard press.modifiers.contains(.command) else {
                    return .ignored
                }
                confirm(inNewTab: true)
                return .handled
            }
            .onSubmit {
                confirm()
            }

            Divider()

            HStack(spacing: 0) {
                results
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                Divider()
                SwitcherPreview(path: selectedPath)
            }

            Divider()

            KeyHintBar(hints: [
                KeyHint(keys: "↑↓", title: String(localized: "Move")),
                KeyHint(keys: "↩", title: String(localized: "Open")),
                KeyHint(keys: "⌘↩", title: String(localized: "Open in New Tab")),
                KeyHint(keys: "esc", title: String(localized: "Close"))
            ])
        }
        .frame(width: EditorMetrics.switcherWidth, height: EditorMetrics.switcherHeight)
        .onAppear {
            isQueryFocused = true
        }
        .onExitCommand {
            Usage.log("quick_switcher_opened_note")
            navigation.isQuickSwitcherShown = false
        }
    }

    // MARK: - Results

    @ViewBuilder
    private var results: some View {
        let matches = switcher.results
        if matches.isEmpty {
            ContentUnavailableView {
                Label(String(localized: "No Matching Notes"), systemImage: "magnifyingglass")
            } description: {
                if switcher.canCreate {
                    Text(String(localized: "Press Return to create “\(switcher.query)”."))
                }
            }
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                            QuickSwitcherRow(match: match, isSelected: index == switcher.selectedIndex, query: switcher.query, detail: detail(of: match))
                                .id(match.id)
                                .onTapGesture {
                                    switcher.select(match)
                                    confirm()
                                }
                        }
                    }
                    .padding(AppSpacing.small)
                }
                .onChange(of: switcher.selectedIndex) { _, index in
                    guard matches.indices.contains(index) else {
                        return
                    }
                    proxy.scrollTo(matches[index].id)
                }
            }
        }
    }

    // MARK: - Derived

    private var selectedPath: NotePath? {
        let matches = switcher.results
        return matches.indices.contains(switcher.selectedIndex) ? matches[switcher.selectedIndex].path : nil
    }

    private func detail(of match: SwitcherMatch) -> String {
        let place = match.path.parent.isRoot ? (vault.rootURL?.lastPathComponent ?? "") : match.path.parent.rawValue
        let aliases = links.map.parsed[match.path]?.aliases ?? []
        guard aliases.isEmpty == false else {
            return place
        }

        return String(localized: "\(place) · also \(aliases.joined(separator: ", "))")
    }

    // MARK: - Actions

    private func confirm(inNewTab: Bool = false) {
        Task {
            guard await switcher.confirm(inNewTab: inNewTab) != nil else {
                return
            }
            navigation.isQuickSwitcherShown = false
        }
    }
}
