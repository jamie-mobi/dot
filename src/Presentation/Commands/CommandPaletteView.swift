//
//  CommandPaletteView.swift
//  Opal
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct CommandPaletteView: View {
    // MARK: - Constants

    private enum Constants {
        static let recentKey = "recentCommands"
        static let separator: Character = ","
    }

    // MARK: - Environment

    @Environment(\.serviceGraph) private var graph
    @Environment(\.windowID) private var windowID
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    @Environment(\.navigationService) private var navigation
    @Environment(\.settingsService) private var settings

    // MARK: - State

    @AppStorage(Constants.recentKey) private var recentText = ""
    @AppStorage(EditorPreferences.liveMarkdownKey) private var isLiveMarkdown = true
    @State private var query = ""
    @State private var selectedIndex = 0

    // MARK: - View

    var body: some View {
        let sections = self.sections
        let shown = sections.flatMap(\.commands)
        CommandPanelView(
            symbol: "command",
            placeholder: String(localized: "Run a command"),
            query: $query,
            hints: [
                KeyHint(keys: "↑↓", title: String(localized: "Move")),
                KeyHint(keys: "↩", title: String(localized: "Run"))
            ],
            scrollTarget: shown.indices.contains(selectedIndex) ? AnyHashable(shown[selectedIndex]) : nil,
            onMove: { delta in
                selectedIndex = min(max(selectedIndex + delta, 0), max(shown.count - 1, 0))
            },
            onSubmit: runSelected
        ) {
            if shown.isEmpty {
                PanelEmptyRow(title: String(localized: "No Matching Commands"))
            }
            ForEach(sections) { section in
                if section.title.isEmpty == false {
                    Text(section.title)
                        .font(AppFont.label)
                        .foregroundStyle(AppColor.quietText)
                        .padding(.horizontal, AppSpacing.comfortable)
                        .padding(.top, AppSpacing.small)
                }

                ForEach(section.commands) { command in
                    CommandRow(
                        command: command,
                        keys: command.shortcut(in: settings.settings.shortcuts)?.keyCaps ?? [],
                        isSelected: shown.firstIndex(of: command) == selectedIndex,
                        isEnabled: runner.isEnabled(command)
                    ) {
                        selectedIndex = shown.firstIndex(of: command) ?? 0
                        runSelected()
                    }
                    .id(command)
                }
            }
        }
        .onChange(of: query) { selectedIndex = 0 }
    }

    // MARK: - Commands

    private var runner: AppCommandRunner {
        AppCommandRunner(
            graph: graph,
            windowID: windowID,
            windows: AppDependencies.shared.windows,
            shortcuts: settings.settings.shortcuts,
            toggleLiveMarkdown: { isLiveMarkdown.toggle() },
            openSettings: { openSettings() },
            openWindow: { openWindow(value: $0) }
        )
    }

    private var recent: [String] {
        recentText.split(separator: Constants.separator).map(String.init)
    }

    private var sections: [CommandSection] {
        let all = AppCommand.allCases.filter { $0 != .commandPalette }
        let names = Dictionary(uniqueKeysWithValues: all.map { ($0.id, "\($0.group) \($0.title)") })
        let ordered = CommandMatchUseCase.ordered(ids: all.map(\.id), names: names, query: query, recent: recent)
            .compactMap(AppCommand.init(rawValue:))
        let isFiltering = query.trimmingCharacters(in: .whitespaces).isEmpty == false
        return CommandSection.sections(ordered: ordered, recent: recent, isFiltering: isFiltering)
    }

    private func runSelected() {
        let shown = sections.flatMap(\.commands)
        guard shown.indices.contains(selectedIndex), runner.isEnabled(shown[selectedIndex]) else {
            return
        }

        let command = shown[selectedIndex]
        recentText = CommandMatchUseCase.recording(command.id, in: recent).joined(separator: String(Constants.separator))
        navigation.isCommandPaletteShown = false
        Task {
            try? await Task.sleep(for: AppMotion.dismissDelay)
            runner.run(command)
        }
    }
}
