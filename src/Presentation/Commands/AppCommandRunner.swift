//
//  AppCommandRunner.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import SwiftUI

@MainActor
struct AppCommandRunner {
    // MARK: - Dependencies

    let graph: ServiceGraph
    let windowID: UUID?
    let windows: WindowRegistry
    let shortcuts: [String: ShortcutChoice]
    let toggleLiveMarkdown: () -> Void
    let openSettings: () -> Void
    let openWindow: (UUID) -> Void
    var closeWindow: (UUID) -> Void = { _ in }

    private var pack: PackService { graph.pack }
    private var notes: NoteService { graph.notes }
    private var navigation: NavigationService { graph.navigation }
    private var switcher: QuickSwitcherService { graph.switcher }
    private var search: SearchService { graph.search }
    private var dailyNotes: DailyNoteService { graph.dailyNotes }
    private var templates: TemplateService { graph.templates }

    // MARK: - State

    func isEnabled(_ command: AppCommand) -> Bool {
        guard windowID != nil || command == .settings || command == .newWindow else {
            return false
        }

        return switch command {
        case .settings, .newWindow, .openPack, .openNote, .createPack, .toggleInspector, .toggleLiveMarkdown, .commandPalette:
            true
        case .newNote, .newFolder, .reloadPack, .quickSwitcher, .dailyNote, .searchPack, .home, .back, .forward, .newTab, .closeTab, .nextTab, .previousTab:
            pack.isOpen
        case .duplicateNote, .toggleStar, .save, .insertTemplate, .toggleReadingView, .revealInFolderTree:
            notes.path != nil
        case .splitRight:
            pack.isOpen && navigation.panes.isSplit == false
        }
    }

    // MARK: - Run

    func run(_ command: AppCommand) {
        guard isEnabled(command) else {
            return
        }

        Usage.feature(command)
        switch command {
        case .settings:
            openSettings()
        case .newWindow:
            openWindow(windows.newWindow())
        case .newNote:
            Task { await PackActions.createNote(pack: pack, navigation: navigation) }
        case .duplicateNote:
            if let path = notes.path {
                Task { await PackActions.duplicate(path, pack: pack, navigation: navigation) }
            }
        case .toggleStar:
            if let path = notes.path {
                Task { await graph.stars.toggle(path) }
            }
        case .newFolder:
            Task { await PackActions.createFolder(pack: pack, notes: notes) }
        case .openPack:
            Task { await PackActions.openPack(graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow) }
        case .openNote:
            Task { await PackActions.openNote(graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow) }
        case .createPack:
            Task { await PackActions.createPack(graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow) }
        case .save:
            Task { await notes.flush() }
        case .reloadPack:
            Task { await PackActions.reloadPack(pack: pack, notes: notes) }
        case .insertTemplate:
            templates.showPicker()
        case .commandPalette:
            navigation.isCommandPaletteShown = true
        case .quickSwitcher:
            Task { await PackActions.showQuickSwitcher(switcher: switcher, navigation: navigation) }
        case .dailyNote:
            Task { await dailyNotes.openToday() }
        case .searchPack:
            search.show()
        case .home:
            navigation.showHome()
        case .revealInFolderTree:
            navigation.revealInFolderTree()
        case .back:
            Task { await navigation.goBack() }
        case .forward:
            Task { await navigation.goForward() }
        case .toggleReadingView:
            navigation.isReadingView.toggle()
        case .toggleLiveMarkdown:
            toggleLiveMarkdown()
        case .toggleInspector:
            navigation.isInspectorShown.toggle()
        case .splitRight:
            Task { await navigation.splitRight() }
        case .newTab:
            Task { await navigation.openInNewTab(nil) }
        case .closeTab:
            Task { await navigation.closeSelectedTab() }
        case .nextTab:
            Task { await navigation.selectNeighbourTab(by: 1) }
        case .previousTab:
            Task { await navigation.selectNeighbourTab(by: -1) }
        }
    }

    // MARK: - Menu

    func keyboardShortcut(_ command: AppCommand) -> KeyboardShortcut? {
        command.shortcut(in: shortcuts)?.keyboardShortcut
    }

    func button(_ command: AppCommand, title: String? = nil) -> some View {
        Button(title ?? command.title) {
            run(command)
        }
        .disabled(isEnabled(command) == false)
        .keyboardShortcut(keyboardShortcut(command))
    }
}
