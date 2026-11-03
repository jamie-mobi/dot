//
//  AppDependencies.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import AppKit
import OpalCore
import OpalDesign

@MainActor
enum AppDependencies {
    // MARK: - Graph

    static let shared = makeGraph()

    private static func defaultIndexBaseURL() -> URL {
        URL.applicationSupportDirectory.appending(path: "Opal/Indexes", directoryHint: .isDirectory)
    }

    static func makeGraph() -> AppGraph {
        let arguments = LaunchArguments(ProcessInfo.processInfo.arguments)
        let defaults = arguments.defaultsSuite.flatMap(UserDefaults.init(suiteName:)) ?? .standard
        AppAccent.current = defaults.string(forKey: AppAccent.key).flatMap(AppAccent.init(rawValue:)) ?? .defaultValue

        let reopensVaults = UserDefaultsSettingsStore(defaults: defaults).settings().reopensVaultsAtLaunch || arguments.forcesRestore

        let recents = RecentVaultsService(access: SecurityScopedVaultAccess(), locations: UserDefaultsVaultLocationStore(defaults: defaults))

        return AppGraph(
            makeVault: { id, isFirst in
                VaultService(
                    access: SecurityScopedVaultAccess(),
                    locations: UserDefaultsVaultLocationStore(defaults: defaults, windowID: id, fallsBackToLastVault: isFirst && reopensVaults),
                    launchVaultURL: isFirst ? arguments.vaultURL : nil,
                    recents: recents,
                    makeWatcher: { FSEventsVaultWatcher(rootURL: $0) },
                    makeStore: { FileSystemVaultStore(rootURL: $0) }
                )
            },
            indexBaseURL: arguments.indexFolderURL ?? defaultIndexBaseURL(),
            defaults: defaults,
            recents: recents,
            launchRequest: arguments.request,
            launchVaultURL: arguments.vaultURL,
            restoresState: arguments.restoresState,
            restoresWindows: reopensVaults,
            launchAppearance: arguments.appearanceName,
            launchSnapshotURL: arguments.snapshotURL
        )
    }
}
