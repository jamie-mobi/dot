//
//  AppGraph.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import AppKit
import DotCore

@MainActor
struct AppGraph {
    // MARK: - App-wide

    let windows: WindowRegistry
    let settings: SettingsService
    let placeholder: ServiceGraph
    let recents: RecentPacksService
    let updates: UpdateService

    // MARK: - Launch

    let launchRequest: LaunchRequest
    let launchPackURL: URL?
    let restoresState: Bool
    let launchAppearance: NSAppearance.Name?
    let launchSnapshotURL: URL?
    let checksForUpdates: Bool
    let defaults: UserDefaults

    // MARK: - Init

    init(
        makePack: @escaping @MainActor (_ windowID: UUID, _ isFirst: Bool) -> PackService,
        indexBaseURL: URL,
        defaults: UserDefaults,
        recents: RecentPacksService,
        launchRequest: LaunchRequest = LaunchRequest(),
        launchPackURL: URL? = nil,
        restoresState: Bool = true,
        restoresWindows: Bool = true,
        launchAppearance: NSAppearance.Name? = nil,
        launchSnapshotURL: URL? = nil,
        checksForUpdates: Bool = false
    ) {
        let settings = SettingsService(store: UserDefaultsSettingsStore(defaults: defaults), clock: SystemClock())
        let recentNotes = UserDefaultsRecentNotesStore(defaults: defaults)
        let starredNotes = UserDefaultsStarredNotesStore(defaults: defaults)
        let folderColourStore = UserDefaultsFolderColourStore(defaults: defaults)
        let windowStore = UserDefaultsWindowListStore(defaults: defaults)
        let makeGraph: @MainActor (PackService, UUID) -> ServiceGraph = { pack, windowID in
            ServiceGraph(
                pack: pack,
                makeIndex: { root throws(IndexError) in
                    try GRDBIndexStore(folderURL: IndexLocation.folder(forPackAt: root, in: indexBaseURL))
                },
                recents: recentNotes,
                starred: starredNotes,
                folderColours: folderColourStore,
                windowID: windowID,
                windows: windowStore,
                settings: settings,
                clock: SystemClock(),
                tagSuggester: FoundationModelsTagSuggester()
            )
        }
        self.settings = settings
        self.recents = recents
        updates = UpdateService()
        self.checksForUpdates = checksForUpdates
        windows = WindowRegistry(store: windowStore, restoresWindows: restoresWindows) { id, isFirst in
            makeGraph(makePack(id, isFirst), id)
        }
        let placeholderID = UUID()
        placeholder = makeGraph(makePack(placeholderID, false), placeholderID)
        settings.detach(placeholder.pack)
        self.launchRequest = launchRequest
        self.launchPackURL = launchPackURL
        self.restoresState = restoresState
        self.launchAppearance = launchAppearance
        self.launchSnapshotURL = launchSnapshotURL
        self.defaults = defaults
    }
}
