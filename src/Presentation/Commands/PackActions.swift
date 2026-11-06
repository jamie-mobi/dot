//
//  PackActions.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import DotCore

@MainActor
enum PackActions {
    // MARK: - Pack

    static func openPack(graph: ServiceGraph, windowID: UUID?, windows: WindowRegistry, openWindow: (UUID) -> Void, closeWindow: (UUID) -> Void = { _ in }) async {
        guard let url = PackPanels.choosePackFolder() else {
            return
        }

        await open(WaitingPack(folderURL: url, isNew: false), graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow)
    }

    static func openNote(graph: ServiceGraph, windowID: UUID?, windows: WindowRegistry, openWindow: (UUID) -> Void, closeWindow: (UUID) -> Void = { _ in }) async {
        guard let windowID, let file = PackPanels.chooseNoteFile() else {
            return
        }

        if let location = windows.location(of: file, preferring: windowID) {
            if location.window != windowID {
                openWindow(location.window)
            }
            await windows.graph(for: location.window).navigation.open(location.path)
            return
        }

        guard let folder = PackPanels.choosePackFolder(holding: file) else {
            return
        }

        guard let note = OpenNoteUseCase.path(of: file, in: folder) else {
            PackPanels.explainNoteOutsidePack(note: file, folder: folder)
            return
        }

        await open(WaitingPack(folderURL: folder, isNew: false, note: note), graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow)
    }

    static func createPack(graph: ServiceGraph, windowID: UUID?, windows: WindowRegistry, openWindow: (UUID) -> Void, closeWindow: (UUID) -> Void = { _ in }) async {
        guard let url = PackPanels.chooseNewPackFolder() else {
            return
        }

        await open(WaitingPack(folderURL: url, isNew: true), graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow)
    }

    static func openRecent(_ recent: RecentPack, recents: RecentPacksService, graph: ServiceGraph, windowID: UUID?, windows: WindowRegistry, openWindow: (UUID) -> Void, closeWindow: (UUID) -> Void = { _ in }) async {
        await recents.load()
        guard let chosen = recents.packs.first(where: { $0.id == recent.id }), chosen.isMissing == false else {
            return
        }

        await open(WaitingPack(folderURL: chosen.folderURL, isNew: false), graph: graph, windowID: windowID, windows: windows, openWindow: openWindow, closeWindow: closeWindow)
    }

    static func open(_ waiting: WaitingPack, in graph: ServiceGraph) async {
        await graph.notes.close()
        if waiting.isNew {
            await graph.pack.create(folderURL: waiting.folderURL)
        } else {
            await graph.pack.open(folderURL: waiting.folderURL)
        }
        if let note = waiting.note, graph.pack.isOpen {
            await graph.navigation.open(note)
        }
    }

    private static func open(_ waiting: WaitingPack, graph: ServiceGraph, windowID: UUID?, windows: WindowRegistry, openWindow: (UUID) -> Void, closeWindow: (UUID) -> Void) async {
        guard let windowID else {
            return
        }

        switch windows.decide(opening: waiting.folderURL, from: windowID) {
        case let .bringToFront(other):
            openWindow(other)
            if graph.pack.isShowingWelcome {
                closeWindow(windowID)
            }
        case .openHere:
            await open(waiting, in: graph)
        case .openInNewWindow:
            openWindow(windows.newWindow(opening: waiting))
        }
    }

    static func reloadPack(pack: PackService, notes: NoteService) async {
        await notes.flush()
        await pack.refresh()
    }

    // MARK: - Items

    static func createNote(pack: PackService, navigation: NavigationService) async {
        do {
            let path = try await pack.createNote(openNote: navigation.openNote)
            Usage.log("note_created")
            await navigation.open(path)
        } catch {
            AppLog.error("Creating a Note failed: \(error)")
        }
    }

    static func createFolder(pack: PackService, notes: NoteService) async {
        do {
            _ = try await pack.createFolder(near: notes.path)
        } catch {
            AppLog.error("Creating a Folder failed: \(error)")
        }
    }

    static func showQuickSwitcher(query: String = "", switcher: QuickSwitcherService, navigation: NavigationService) async {
        await switcher.prepare(query: query)
        navigation.isQuickSwitcherShown = true
    }

    static func duplicate(_ path: NotePath, pack: PackService, navigation: NavigationService) async {
        do {
            let copy = try await pack.duplicate(path)
            Usage.log("note_duplicated")
            await navigation.open(copy)
        } catch {
            AppLog.error("Duplicating \(path) failed: \(error)")
        }
    }

    static func follow(_ link: Link, from source: NotePath, pack: PackService, navigation: NavigationService) async {
        guard case let .attachment(path) = await navigation.follow(link, from: source) else {
            return
        }

        openInDefaultApp(path, pack: pack)
    }

    static func reveal(_ path: NotePath, pack: PackService) {
        guard let url = pack.url(for: path) else {
            return
        }

        WorkspaceActions.revealInFinder(url)
    }

    static func openInDefaultApp(_ path: NotePath, pack: PackService) {
        guard let url = pack.url(for: path) else {
            return
        }

        WorkspaceActions.openInDefaultApp(url)
    }
}
