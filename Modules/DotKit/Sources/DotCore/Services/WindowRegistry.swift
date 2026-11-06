//
//  WindowRegistry.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class WindowRegistry {
    // MARK: - State

    @ObservationIgnored public private(set) var windowIDs: [UUID]
    public let restoredIDs: [UUID]
    public var isQuitting = false
    public private(set) var activeWindowID: UUID?

    public var activeGraph: ServiceGraph? {
        activeWindowID.flatMap { graphs[$0] }
    }

    public var firstWindowID: UUID {
        windowIDs.first ?? restoredIDs.first ?? fallbackID
    }

    // MARK: - Private

    private let store: any WindowListStoring
    private let restoresWindows: Bool
    private let makeGraph: @MainActor (UUID, Bool) -> ServiceGraph
    private let fallbackID = UUID()
    @ObservationIgnored private var graphs: [UUID: ServiceGraph] = [:]
    @ObservationIgnored private var waitingPacks: [UUID: WaitingPack] = [:]

    // MARK: - Init

    public init(store: any WindowListStoring, restoresWindows: Bool = true, makeGraph: @escaping @MainActor (_ id: UUID, _ isFirst: Bool) -> ServiceGraph) {
        self.store = store
        self.restoresWindows = restoresWindows
        self.makeGraph = makeGraph
        restoredIDs = restoresWindows ? store.windowIDs() : []
        windowIDs = []
    }

    // MARK: - Graphs

    public func graph(for id: UUID) -> ServiceGraph {
        if let graph = graphs[id] {
            return graph
        }

        let graph = makeGraph(id, id == firstWindowID)
        graphs[id] = graph
        if windowIDs.contains(id) == false {
            windowIDs.append(id)
            saveWindowList()
        }
        return graph
    }

    public func window(showing folderURL: URL) -> UUID? {
        guard case let .bringToFront(id) = OpenPackUseCase.decide(opening: folderURL, from: UUID(), roots: roots) else {
            return nil
        }

        return id
    }

    public func location(of fileURL: URL, preferring id: UUID?) -> NoteLocation? {
        OpenNoteUseCase.locate(fileURL, roots: roots, preferring: id)
    }

    public func activate(_ id: UUID) {
        guard graphs[id] != nil, activeWindowID != id else {
            return
        }

        activeWindowID = id
    }

    public func decide(opening folderURL: URL, from id: UUID) -> OpenPackDecision {
        OpenPackUseCase.decide(opening: folderURL, from: id, roots: roots)
    }

    public func welcomeWindows(besides id: UUID) -> [UUID] {
        graphs.filter { key, graph in
            key != id && waitingPacks[key] == nil && graph.pack.isShowingWelcome
        }
        .map(\.key)
    }

    // MARK: - New windows

    public func defaultWindowID() -> UUID {
        graphs.isEmpty ? firstWindowID : UUID()
    }

    public func newWindow(opening waiting: WaitingPack? = nil) -> UUID {
        let id = UUID()
        waitingPacks[id] = waiting
        return id
    }

    public func takeWaitingPack(for id: UUID) -> WaitingPack? {
        waitingPacks.removeValue(forKey: id)
    }

    // MARK: - Frames

    public func savedFrame(for id: UUID) -> WindowFrame? {
        store.windowState(for: id)?.frame
    }

    public func setFrame(_ frame: WindowFrame, for id: UUID) {
        guard windowIDs.contains(id) else {
            return
        }

        store.updateWindowState(for: id) { $0.frame = frame }
    }

    // MARK: - Closing

    public func close(_ id: UUID) async {
        guard let graph = graphs.removeValue(forKey: id) else {
            return
        }

        if activeWindowID == id {
            activeWindowID = windowIDs.last { $0 != id && graphs[$0] != nil }
        }

        await graph.notes.flush()
        guard isQuitting == false else {
            return
        }

        graph.pack.close()
        graph.settings.detach(graph.pack)
        windowIDs.removeAll { $0 == id }
        saveWindowList()
        store.setWindowState(nil, for: id)
    }

    public func flushAll() async {
        for graph in graphs.values {
            await graph.notes.flush()
        }

        if isQuitting, restoresWindows == false {
            for id in windowIDs {
                store.setWindowState(nil, for: id)
            }
        }
    }

    // MARK: - Private

    private func saveWindowList() {
        if restoresWindows {
            store.setWindowIDs(windowIDs)
        }
    }

    private var roots: [UUID: URL] {
        graphs.compactMapValues(\.pack.rootURL)
    }
}
