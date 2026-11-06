//
//  ShortcutsSettingsView.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import DotCore
import DotDesign
import SwiftUI

struct ShortcutsSettingsView: View {
    // MARK: - Constants

    private enum Constants {
        static let escapeKeyCode: UInt16 = 53
        static let returnKeyCodes: Set<UInt16> = [36, 76]
    }

    // MARK: - Environment

    @Environment(\.settingsService) private var settings

    // MARK: - State

    @State private var filter = ""
    @State private var recording: AppCommand?
    @State private var message: String?
    @State private var conflict: ShortcutConflict?
    @State private var isConfirmingRestoreAll = false

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            list
            Divider()
            HStack {
                Spacer()
                Button(String(localized: "Restore All Defaults…")) {
                    isConfirmingRestoreAll = true
                }
                .disabled(settings.settings.shortcuts.isEmpty)
            }
            .padding(AppSpacing.regular)
        }
        .frame(height: EditorMetrics.windowMinHeight)
        .recordsShortcut(isActive: recording != nil, onKey: handle)
        .onAppear(perform: applyLaunchState)
        .confirmationDialog(String(localized: "Restore All Shortcuts?"), isPresented: $isConfirmingRestoreAll) {
            Button(String(localized: "Restore All")) {
                stopRecording()
                settings.settings.shortcuts = [:]
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "Every command goes back to Dot's shortcut."))
        }
    }

    private var list: some View {
        Form {
            TextField(String(localized: "Filter shortcuts"), text: $filter)
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
    }

    // MARK: - Rows

    private func row(_ command: AppCommand) -> some View {
        let isConflicted = recording == command && conflict != nil
        let onReplace: (() -> Void)? = isConflicted ? { replace() } : nil
        let onCancel: (() -> Void)? = isConflicted ? { stopRecording() } : nil
        let onRemove: (() -> Void)? = command.shortcut(in: settings.settings.shortcuts) == nil ? nil : { remove(command) }
        let onRestore: (() -> Void)? = settings.settings.shortcuts[command.id] == nil ? nil : { restore(command) }
        return ShortcutRow(
            title: command.title,
            shortcut: isConflicted ? conflict?.shortcut : command.shortcut(in: settings.settings.shortcuts),
            isRecording: recording == command && isConflicted == false,
            message: recording == command ? message : nil,
            onReplace: onReplace,
            onCancel: onCancel,
            onRemove: onRemove,
            onRestore: onRestore
        ) {
            let wasRecording = recording == command
            stopRecording()
            recording = wasRecording ? nil : command
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
            stopRecording()
            return
        }

        guard conflict == nil else {
            if Constants.returnKeyCodes.contains(event.keyCode) {
                replace()
            }
            return
        }

        guard let shortcut = CommandShortcut(event: event) else {
            return
        }

        if let problem = ShortcutUseCase.problem(with: shortcut) {
            message = words(for: problem, shortcut: shortcut)
            return
        }

        if let other = holder(of: shortcut, otherThan: command) {
            conflict = ShortcutConflict(shortcut: shortcut, other: other)
            message = String(localized: "Used by \(other.title)")
            return
        }

        settings.settings.shortcuts = ShortcutUseCase.saving(shortcut, for: command.id, fallback: command.defaultShortcut, in: settings.settings.shortcuts)
        stopRecording()
    }

    private func replace() {
        guard let command = recording, let conflict else {
            return
        }

        settings.settings.shortcuts = ShortcutUseCase.replacing(
            conflict.other.id,
            with: conflict.shortcut,
            for: command.id,
            fallback: command.defaultShortcut,
            in: settings.settings.shortcuts
        )
        stopRecording()
    }

    private func remove(_ command: AppCommand) {
        stopRecording()
        settings.settings.shortcuts = ShortcutUseCase.removing(for: command.id, fallback: command.defaultShortcut, in: settings.settings.shortcuts)
    }

    private func restore(_ command: AppCommand) {
        stopRecording()
        if let fallback = command.defaultShortcut, let other = holder(of: fallback, otherThan: command) {
            recording = command
            conflict = ShortcutConflict(shortcut: fallback, other: other)
            message = String(localized: "Used by \(other.title)")
            return
        }

        settings.settings.shortcuts = ShortcutUseCase.restoring(for: command.id, in: settings.settings.shortcuts)
    }

    private func stopRecording() {
        message = nil
        conflict = nil
        recording = nil
    }

    private func holder(of shortcut: CommandShortcut, otherThan command: AppCommand) -> AppCommand? {
        ShortcutUseCase.holder(
            of: shortcut,
            otherThan: command.id,
            fallbacks: AppCommand.defaultShortcuts,
            saved: settings.settings.shortcuts,
            ids: AppCommand.allCases.map(\.id)
        ).flatMap(AppCommand.init(rawValue:))
    }

    private func words(for problem: ShortcutProblem, shortcut: CommandShortcut) -> String {
        switch problem {
        case .needsModifier:
            String(localized: "Include ⌘ or ⌃")
        case .usedByMacOS:
            String(localized: "\(shortcut.text) is used by macOS")
        case .usedForEditing:
            String(localized: "\(shortcut.text) is used for editing")
        }
    }

    // MARK: - Launch

    private func applyLaunchState() {
        #if DEBUG
            guard let state = AppDependencies.shared.launchRequest.shortcutState else {
                return
            }

            recording = .newNote
            switch state {
            case "conflict":
                let other = AppCommand.newTab
                conflict = other.defaultShortcut.map { ShortcutConflict(shortcut: $0, other: other) }
                message = String(localized: "Used by \(other.title)")
            case "reserved":
                message = words(for: .usedByMacOS, shortcut: CommandShortcut("q"))
            default:
                break
            }
        #endif
    }
}
