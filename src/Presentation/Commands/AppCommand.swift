//
//  AppCommand.swift
//  Opal
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import OpalCore

enum AppCommand: String, CaseIterable, Identifiable {
    case settings
    case newWindow
    case newNote
    case duplicateNote
    case newFolder
    case openVault
    case createVault
    case save
    case reloadVault
    case insertTemplate
    case commandPalette
    case quickSwitcher
    case dailyNote
    case searchVault
    case back
    case forward
    case toggleReadingView
    case toggleLiveMarkdown
    case toggleInspector
    case splitRight
    case newTab
    case closeTab
    case nextTab
    case previousTab

    // MARK: - Identifiable

    var id: String {
        rawValue
    }

    // MARK: - Display

    var title: String {
        switch self {
        case .settings:
            String(localized: "Settings…")
        case .newWindow:
            String(localized: "New Window")
        case .newNote:
            String(localized: "New Note")
        case .duplicateNote:
            String(localized: "Duplicate Note")
        case .newFolder:
            String(localized: "New Folder")
        case .openVault:
            String(localized: "Open Vault…")
        case .createVault:
            String(localized: "Create Vault…")
        case .save:
            String(localized: "Save")
        case .reloadVault:
            String(localized: "Reload Vault")
        case .insertTemplate:
            String(localized: "Insert Template…")
        case .commandPalette:
            String(localized: "Command Palette…")
        case .quickSwitcher:
            String(localized: "Quick Switcher…")
        case .dailyNote:
            String(localized: "Today's Daily Note")
        case .searchVault:
            String(localized: "Search Vault…")
        case .back:
            String(localized: "Back")
        case .forward:
            String(localized: "Forward")
        case .toggleReadingView:
            String(localized: "Toggle Reading View")
        case .toggleLiveMarkdown:
            String(localized: "Toggle Live Markdown")
        case .toggleInspector:
            String(localized: "Toggle Inspector")
        case .splitRight:
            String(localized: "Split Right")
        case .newTab:
            String(localized: "New Tab")
        case .closeTab:
            String(localized: "Close Tab")
        case .nextTab:
            String(localized: "Next Tab")
        case .previousTab:
            String(localized: "Previous Tab")
        }
    }

    var group: String {
        switch self {
        case .settings:
            String(localized: "Opal")
        case .newWindow, .newNote, .duplicateNote, .newFolder, .openVault, .createVault, .save, .reloadVault, .newTab, .closeTab:
            String(localized: "File")
        case .insertTemplate:
            String(localized: "Edit")
        case .commandPalette, .quickSwitcher, .dailyNote, .searchVault, .back, .forward, .nextTab, .previousTab:
            String(localized: "Go")
        case .toggleReadingView, .toggleLiveMarkdown, .toggleInspector, .splitRight:
            String(localized: "View")
        }
    }

    // MARK: - Shortcut

    var defaultShortcut: CommandShortcut? {
        switch self {
        case .newNote:
            CommandShortcut("n")
        case .newFolder:
            CommandShortcut("n", [.command, .option])
        case .newWindow:
            CommandShortcut("n", [.command, .shift])
        case .openVault:
            CommandShortcut("o", [.command, .shift])
        case .save:
            CommandShortcut("s")
        case .reloadVault:
            CommandShortcut("r")
        case .insertTemplate:
            CommandShortcut("t", [.command, .option])
        case .commandPalette:
            CommandShortcut("p", [.command, .shift])
        case .quickSwitcher:
            CommandShortcut("o")
        case .dailyNote:
            CommandShortcut("d", [.command, .option])
        case .searchVault:
            CommandShortcut("f", [.command, .shift])
        case .back:
            CommandShortcut("[")
        case .forward:
            CommandShortcut("]")
        case .toggleReadingView:
            CommandShortcut("e")
        case .toggleInspector:
            CommandShortcut("0", [.command, .option])
        case .splitRight:
            CommandShortcut("\\")
        case .settings:
            CommandShortcut(",")
        case .newTab:
            CommandShortcut("t")
        case .closeTab:
            CommandShortcut("w")
        case .nextTab:
            CommandShortcut("tab", [.control])
        case .previousTab:
            CommandShortcut("tab", [.control, .shift])
        case .duplicateNote, .createVault, .toggleLiveMarkdown:
            nil
        }
    }

    func shortcut(in saved: [String: ShortcutChoice]) -> CommandShortcut? {
        ShortcutUseCase.effective(for: id, fallback: defaultShortcut, saved: saved)
    }
}
