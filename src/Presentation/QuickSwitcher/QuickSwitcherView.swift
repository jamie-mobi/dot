//
//  QuickSwitcherView.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct QuickSwitcherView: View {
    // MARK: - Environment

    @Environment(\.quickSwitcherService) private var switcher
    @Environment(\.navigationService) private var navigation
    @Environment(\.linkService) private var links
    @Environment(\.packService) private var pack
    @Environment(\.folderColourService) private var folderColours

    // MARK: - View

    var body: some View {
        @Bindable var switcher = switcher
        let matches = switcher.results
        CommandPanelView(
            symbol: "magnifyingglass",
            placeholder: String(localized: "Find a Note"),
            query: $switcher.query,
            shortcut: ["⌘O"],
            hints: [
                KeyHint(keys: "↑↓", title: String(localized: "Move")),
                KeyHint(keys: "↩", title: String(localized: "Open")),
                KeyHint(keys: "⌘↩", title: String(localized: "Open in New Tab"))
            ],
            scrollTarget: matches.indices.contains(switcher.selectedIndex) ? AnyHashable(matches[switcher.selectedIndex].id) : nil,
            onMove: { switcher.moveSelection(by: $0) },
            onSubmit: { confirm() },
            onCommandSubmit: { confirm(inNewTab: true) }
        ) {
            if matches.isEmpty {
                PanelEmptyRow(
                    title: String(localized: "No Matching Notes"),
                    detail: switcher.canCreate ? String(localized: "Press Return to create “\(switcher.query)”.") : ""
                )
            }
            ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                QuickSwitcherRow(
                    match: match,
                    query: switcher.query,
                    location: location(of: match),
                    colour: folderColours.colour(for: match.path)?.color ?? AppLabelColor.neutral,
                    isSelected: index == switcher.selectedIndex
                ) {
                    switcher.select(match)
                    confirm()
                }
                .id(match.id)
            }
        }
    }

    // MARK: - Derived

    private func location(of match: SwitcherMatch) -> String {
        let place = match.path.parent.isRoot ? (pack.rootURL?.lastPathComponent ?? "") : match.path.parent.rawValue
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
            Usage.log("quick_switcher_opened_note")
            navigation.isQuickSwitcherShown = false
        }
    }
}
