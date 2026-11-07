//
//  AppDependencies.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import AppKit
import DotCore
import DotDesign

@MainActor
enum AppDependencies {
    // MARK: - Graph

    static let shared = makeGraph()

    private static func defaultIndexBaseURL() -> URL {
        URL.applicationSupportDirectory.appending(path: "Dot/Indexes", directoryHint: .isDirectory)
    }

    static func makeGraph() -> AppGraph {
        let arguments = LaunchArguments(ProcessInfo.processInfo.arguments)
        let defaults = arguments.defaultsSuite.flatMap(UserDefaults.init(suiteName:)) ?? .standard
        AppAccent.current = defaults.string(forKey: AppAccent.key).flatMap(AppAccent.init(rawValue:)) ?? .defaultValue

        let reopensPacks = UserDefaultsSettingsStore(defaults: defaults).settings().reopensPacksAtLaunch || arguments.forcesRestore

        let recents = RecentPacksService(access: SecurityScopedPackAccess(), locations: UserDefaultsPackLocationStore(defaults: defaults))

        return AppGraph(
            makePack: { id, isFirst in
                PackService(
                    access: SecurityScopedPackAccess(),
                    locations: UserDefaultsPackLocationStore(defaults: defaults, windowID: id, fallsBackToLastPack: isFirst && reopensPacks),
                    launchPackURL: isFirst ? arguments.packURL : nil,
                    recents: recents,
                    makeWatcher: { FSEventsPackWatcher(rootURL: $0) },
                    makeStore: { FileSystemPackStore(rootURL: $0) }
                )
            },
            indexBaseURL: arguments.indexFolderURL ?? defaultIndexBaseURL(),
            defaults: defaults,
            recents: recents,
            launchRequest: arguments.request,
            launchPackURL: arguments.packURL,
            restoresState: arguments.restoresState,
            restoresWindows: reopensPacks,
            launchAppearance: arguments.appearanceName,
            launchSnapshotURL: arguments.snapshotURL,
            checksForUpdates: arguments.checksForUpdates
        )
    }
}
