//
//  PackService.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class PackService: SingleFlightRefreshing {
    // MARK: - State

    public enum LoadState: Hashable, Sendable {
        case closed(PackError?)
        case opening
        case open(Pack)
    }

    public var loadState: LoadState {
        switch (isOpening, pack) {
        case (true, _):
            .opening
        case (false, let pack?):
            .open(pack)
        case (false, nil):
            .closed(error)
        }
    }

    public var isOpen: Bool {
        pack != nil && isOpening == false
    }

    public var isShowingWelcome: Bool {
        switch loadState {
        case .closed(nil):
            true
        case .closed(.some), .opening, .open:
            false
        }
    }

    public private(set) var tree: [PackTreeNode] = []
    public private(set) var packSettings = PackSettings()
    public var dotSettings = DotSettings.defaults

    public var appSettings: ObsidianAppSettings {
        SettingsUseCase.appSettings(dotSettings, pack: packSettings)
    }

    public var dailyNoteSettings: DailyNoteSettings {
        SettingsUseCase.dailyNoteSettings(dotSettings, pack: packSettings)
    }

    public var linkUpdate: LinkUpdate {
        SettingsUseCase.linkUpdate(dotSettings, pack: packSettings)
    }
    public private(set) var propertyTypes: [String: PropertyType] = [:]
    public private(set) var templateSettings = TemplateSettings.defaults
    public private(set) var store: (any PackFileStoring)?
    public private(set) var entries: [PackEntry] = []
    public private(set) var entriesRevision = 0

    // MARK: - SingleFlightRefreshing

    public var refreshTask: Task<Void, Never>?

    // MARK: - Changes from outside

    public var onExternalChange: (@MainActor (Set<NotePath>) async -> Void)?

    // MARK: - Private

    private let access: any PackAccessGranting
    private let locations: any PackLocationStoring
    private let recents: RecentPacksService?
    private let launchPackURL: URL?
    private let makeStore: @Sendable (URL) -> any PackFileStoring
    private let makeWatcher: (@Sendable (URL) -> any PackWatching)?

    private var pack: Pack?
    private var kinds: [NotePath: PackItemKind] = [:]
    private var isOpening = false
    private var error: PackError?
    private var hasStarted = false
    private var accessedURL: URL?
    @ObservationIgnored private var watchTask: Task<Void, Never>?

    // MARK: - Init

    public init(
        access: any PackAccessGranting,
        locations: any PackLocationStoring,
        launchPackURL: URL?,
        recents: RecentPacksService? = nil,
        makeWatcher: (@Sendable (URL) -> any PackWatching)? = nil,
        makeStore: @escaping @Sendable (URL) -> any PackFileStoring
    ) {
        self.access = access
        self.locations = locations
        self.launchPackURL = launchPackURL
        self.recents = recents
        self.makeWatcher = makeWatcher
        self.makeStore = makeStore
    }

    // MARK: - Intent

    public func start() async {
        guard hasStarted == false else {
            return
        }

        hasStarted = true
        if let launchPackURL {
            await openPack(at: launchPackURL, remember: false, records: false)
        } else {
            await restoreLastPack()
        }
    }

    public func open(folderURL: URL) async {
        await openPack(at: folderURL, remember: true)
    }

    public func close() {
        closeCurrentPack()
    }

    public var rootURL: URL? {
        pack?.rootURL
    }

    public func create(folderURL: URL) async {
        do {
            try access.createPackFolder(at: folderURL)
        } catch {
            closeCurrentPack()
            self.error = error
            return
        }

        await openPack(at: folderURL, remember: true)
    }

    public func kind(of path: NotePath) -> PackItemKind? {
        kinds[path]
    }

    public func url(for path: NotePath) -> URL? {
        store?.url(for: path)
    }

    public func createNote(openNote: NotePath?) async throws(PackError) -> NotePath {
        guard let store else {
            throw .noPackOpen
        }

        let folder = NewItemPlanUseCase.folderForNewNote(settings: appSettings, openNote: openNote)
        let path = NewItemPlanUseCase.newNotePath(in: folder, existing: Set(kinds.keys))
        try await store.createNote(at: path, text: "")
        insert(PackEntry(path: path, kind: .note))
        return path
    }

    public func createNote(at path: NotePath, text: String = "") async throws(PackError) {
        guard let store else {
            throw .noPackOpen
        }

        try await store.createNote(at: path, text: text)
        insert(PackEntry(path: path, kind: .note))
    }

    public func duplicate(_ path: NotePath) async throws(PackError) -> NotePath {
        guard let store else {
            throw .noPackOpen
        }
        guard path.isNote, let text = try await store.readNote(at: path) else {
            throw .notFound(path)
        }

        var taken = Set(entries.map(\.path))
        while let copy = AttachmentUseCase.availablePath(named: path.fileName, in: path.parent, existing: taken) {
            do {
                try await store.createNote(at: copy, text: text)
            } catch .alreadyExists {
                taken.insert(copy)
                continue
            }
            insert(PackEntry(path: copy, kind: .note))
            return copy
        }
        throw .alreadyExists(path)
    }

    public func createAttachment(_ data: Data, named fileName: String, for note: NotePath) async throws(PackError) -> NotePath {
        guard let store else {
            throw .noPackOpen
        }

        let folder = AttachmentUseCase.folder(for: note, attachmentFolderPath: appSettings.attachmentFolderPath)
        var taken = Set(entries.map(\.path))
        while let path = AttachmentUseCase.availablePath(named: fileName, in: folder, existing: taken) {
            do {
                try await store.createFile(at: path, data: data)
            } catch .alreadyExists {
                taken.insert(path)
                continue
            }
            insert(PackEntry(path: path, kind: .attachment))
            return path
        }
        throw .alreadyExists(folder.appending(fileName))
    }

    public func createFolder(near selection: NotePath?) async throws(PackError) -> NotePath {
        guard let store else {
            throw .noPackOpen
        }

        let parent = NewItemPlanUseCase.containingFolder(of: selection, kind: selection.flatMap { kinds[$0] })
        let path = NewItemPlanUseCase.newFolderPath(in: parent, existing: Set(kinds.keys))
        try await store.createFolder(at: path)
        insert(PackEntry(path: path, kind: .folder))
        return path
    }

    public func handleExternalChanges(_ paths: Set<NotePath>) async {
        let visible = paths.filter { $0.isHidden == false }
        guard isOpen, visible.isEmpty == false else {
            return
        }

        await refresh()
        await onExternalChange?(visible)
    }

    // MARK: - SingleFlightRefreshing

    public func performRefresh() async {
        guard let store else {
            return
        }

        let listed: [PackEntry]
        do {
            listed = try await store.listEntries()
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            AppLog.error("Reloading the Pack failed: \(error)")
            return
        }

        guard Task.isCancelled == false else {
            return
        }

        guard listed != entries else {
            return
        }

        let newTree = await Self.tree(from: listed)
        guard Task.isCancelled == false else {
            return
        }

        apply(listed, tree: newTree)
    }

    // MARK: - Private

    private func restoreLastPack() async {
        guard let bookmark = await locations.lastPackBookmark() else {
            return
        }

        let resolved: ResolvedPackBookmark
        do {
            resolved = try access.resolve(bookmark: bookmark)
        } catch {
            self.error = error
            return
        }

        await openPack(at: resolved.folderURL, remember: resolved.isStale)
    }

    private func openPack(at folderURL: URL, remember: Bool, records: Bool = true) async {
        refreshTask?.cancel()
        closeCurrentPack()
        isOpening = true
        error = nil

        if access.beginAccess(to: folderURL) {
            accessedURL = folderURL
        }

        if remember {
            do {
                try await locations.setLastPackBookmark(access.bookmark(for: folderURL))
            } catch {
                AppLog.error("Could not remember the Pack: \(error)")
            }
        }

        let newStore = makeStore(folderURL)
        let listed: [PackEntry]
        do {
            listed = try await newStore.listEntries()
        } catch {
            closeCurrentPack()
            self.error = error
            isOpening = false
            return
        }

        let settings = await ObsidianVaultSettingsParser.parse(
            app: newStore.readObsidianSettings(named: ObsidianAppSettingsParser.fileName),
            dailyNotes: newStore.readObsidianSettings(named: ObsidianDailyNotesParser.fileName)
        )

        let types = await ObsidianTypesParser.parse(newStore.readObsidianSettings(named: ObsidianTypesParser.fileName))
        let templates = await ObsidianTemplatesParser.parse(newStore.readObsidianSettings(named: ObsidianTemplatesParser.fileName))

        store = newStore
        packSettings = settings
        propertyTypes = types
        templateSettings = templates ?? .defaults
        pack = Pack(rootURL: folderURL)
        apply(listed, tree: await Self.tree(from: listed))
        isOpening = false
        startWatching(folderURL)
        if records {
            await recents?.record(folderURL)
        }
    }

    private func startWatching(_ folderURL: URL) {
        guard let makeWatcher else {
            return
        }

        let changes = makeWatcher(folderURL).changes()
        watchTask = Task { [weak self] in
            for await paths in changes {
                await self?.handleExternalChanges(paths)
            }
        }
    }

    private func closeCurrentPack() {
        watchTask?.cancel()
        watchTask = nil
        if let accessedURL {
            access.endAccess(to: accessedURL)
        }

        accessedURL = nil
        pack = nil
        store = nil
        packSettings = PackSettings()
        propertyTypes = [:]
        templateSettings = .defaults
        apply([])
    }

    private func insert(_ entry: PackEntry) {
        apply(PackTreeUseCase.entriesAddingAncestors(of: entry, to: entries))
    }

    private func apply(_ newEntries: [PackEntry], tree newTree: [PackTreeNode]? = nil) {
        entries = newEntries
        entriesRevision += 1
        kinds = Dictionary(newEntries.map { ($0.path, $0.kind) }) { first, _ in first }
        tree = newTree ?? PackTreeUseCase.tree(from: newEntries)
    }

    @concurrent
    private nonisolated static func tree(from entries: [PackEntry]) async -> [PackTreeNode] {
        PackTreeUseCase.tree(from: entries)
    }
}
