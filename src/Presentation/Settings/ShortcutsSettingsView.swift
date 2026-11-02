//
//  ShortcutsSettingsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import OpalCore
import OpalDesign
import SwiftUI

struct ShortcutsSettingsView: View {
    // MARK: - Constants

    private enum Constants {
        static let escapeKeyCode: UInt16 = 53
    }

    // MARK: - Environment

    @Environment(\.settingsService) private var settings

    // MARK: - State

    @State private var filter = ""
    @State private var recording: AppCommand?
    @State private var message: String?

    // MARK: - View

    var body: some View {
        Form {
            Section {
                TextField(String(localized: "Filter"), text: $filter)
            }
            ForEach(groups, id: \.self) { group in
                Section(group) {
                    ForEach(commands(in: group)) { command in
                        row(command)
                    }
                }
            }
            if groups.isEmpty {
                ContentUnavailableView(String(localized: "No Commands"), systemImage: "command", description: Text(filter))
            }
        }
        .formStyle(.grouped)
        .frame(height: EditorMetrics.shortcutsListHeight)
        .recordsShortcut(isActive: recording != nil, onKey: handle)
        .onAppear(perform: applyLaunchState)
    }

    // MARK: - Rows

    private func row(_ command: AppCommand) -> some View {
        ShortcutRow(
            title: command.title,
            shortcut: command.shortcut(in: settings.settings.shortcuts),
            isRecording: recording == command,
            message: recording == command ? message : nil
        ) {
            message = nil
            recording = recording == command ? nil : command
        }
    }

    // MARK: - Commands

    private var shown: [AppCommand] {
        let query = filter.trimmingCharacters(in: .whitespaces)
        guard query.isEmpty == false else {
            return AppCommand.allCases
        }

        return AppCommand.allCases.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var groups: [String] {
        var seen: Set<String> = []
        return shown.map(\.group).filter { seen.insert($0).inserted }
    }

    private func commands(in group: String) -> [AppCommand] {
        shown.filter { $0.group == group }
    }

    // MARK: - Recording

    private func handle(_ event: NSEvent) {
        guard let command = recording else {
            return
        }

        guard event.keyCode != Constants.escapeKeyCode else {
            message = nil
            recording = nil
            return
        }

        guard let shortcut = CommandShortcut(event: event) else {
            return
        }

        if let problem = ShortcutUseCase.problem(with: shortcut) {
            message = words(for: problem)
            return
        }

        settings.settings.shortcuts = ShortcutUseCase.saving(shortcut, for: command.id, fallback: command.defaultShortcut, in: settings.settings.shortcuts)
        message = nil
        recording = nil
    }

    private func words(for problem: ShortcutProblem) -> String {
        switch problem {
        case .needsModifier:
            String(localized: "Include ⌘ or ⌃")
        }
    }

    // MARK: - Launch

    private func applyLaunchState() {
        #if DEBUG
            guard let state = AppDependencies.shared.launchRequest.shortcutState else {
                return
            }

            recording = .newNote
            if state == "needsModifier" {
                message = words(for: .needsModifier)
            }
        #endif
    }
}
