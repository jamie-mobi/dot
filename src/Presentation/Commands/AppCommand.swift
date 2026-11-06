//
//  AppCommand.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore

enum AppCommand: String, CaseIterable, Identifiable {
    case settings
    case newWindow
    case newNote
    case duplicateNote
    case toggleStar
    case newFolder
    case openPack
    case openNote
    case createPack
    case save
    case reloadPack
    case insertTemplate
    case commandPalette
    case quickSwitcher
    case dailyNote
    case searchPack
    case home
    case revealInFolderTree
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
        case .toggleStar:
            String(localized: "Star or Unstar Note")
        case .newFolder:
            String(localized: "New Folder")
        case .openPack:
            String(localized: "Open Pack…")
        case .openNote:
            String(localized: "Open Note…")
        case .createPack:
            String(localized: "Create Pack…")
        case .save:
            String(localized: "Save")
        case .reloadPack:
            String(localized: "Reload Pack")
        case .insertTemplate:
            String(localized: "Insert Template…")
        case .commandPalette:
            String(localized: "Command Palette…")
        case .quickSwitcher:
            String(localized: "Quick Switcher…")
        case .dailyNote:
            String(localized: "Today's Daily Note")
        case .searchPack:
            String(localized: "Search")
        case .home:
            String(localized: "Home")
        case .revealInFolderTree:
            String(localized: "Reveal in Folder Tree")
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
            String(localized: "Dot")
        case .newWindow, .newNote, .duplicateNote, .toggleStar, .newFolder, .openPack, .openNote, .createPack, .save, .reloadPack, .newTab, .closeTab:
            String(localized: "File")
        case .insertTemplate:
            String(localized: "Edit")
        case .commandPalette, .quickSwitcher, .dailyNote, .searchPack, .home, .revealInFolderTree, .back, .forward, .nextTab, .previousTab:
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
        case .openPack:
            CommandShortcut("o", [.command, .shift])
        case .openNote:
            CommandShortcut("o", [.command, .option])
        case .save:
            CommandShortcut("s")
        case .reloadPack:
            CommandShortcut("r")
        case .insertTemplate:
            CommandShortcut("t", [.command, .option])
        case .commandPalette:
            CommandShortcut("p", [.command, .shift])
        case .quickSwitcher:
            CommandShortcut("o")
        case .dailyNote:
            CommandShortcut("d", [.command, .option])
        case .searchPack:
            CommandShortcut("f", [.command, .shift])
        case .home:
            CommandShortcut("h", [.command, .shift])
        case .revealInFolderTree:
            CommandShortcut("j", [.option, .shift])
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
        case .duplicateNote, .toggleStar, .createPack, .toggleLiveMarkdown:
            nil
        }
    }

    static var defaultShortcuts: [String: CommandShortcut] {
        Dictionary(uniqueKeysWithValues: allCases.compactMap { command in command.defaultShortcut.map { (command.id, $0) } })
    }

    func shortcut(in saved: [String: ShortcutChoice]) -> CommandShortcut? {
        ShortcutUseCase.effective(for: id, fallback: defaultShortcut, saved: saved)
    }
}
