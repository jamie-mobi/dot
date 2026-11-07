//
//  DotApp.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

@main
struct DotApp: App {
    // MARK: - Environment

    @NSApplicationDelegateAdaptor(DotAppDelegate.self) private var appDelegate

    // MARK: - Scene

    var body: some Scene {
        WindowGroup(for: UUID.self) { $id in
            WindowScreen(id: id)
                .followsAccent()
                .defaultAppStorage(AppDependencies.shared.defaults)
        } defaultValue: {
            AppDependencies.shared.windows.defaultWindowID()
        }
        .windowToolbarStyle(.unified)
        .defaultSize(width: EditorMetrics.windowDefaultWidth, height: EditorMetrics.windowDefaultHeight)
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        .commands {
            DotCommands(
                settings: AppDependencies.shared.settings,
                windows: AppDependencies.shared.windows,
                recents: AppDependencies.shared.recents,
                updates: AppDependencies.shared.updates,
                placeholder: AppDependencies.shared.placeholder,
                defaults: AppDependencies.shared.defaults
            )
        }

        Settings {
            SettingsScreen()
                .followsAccent()
                .defaultAppStorage(AppDependencies.shared.defaults)
        }
    }
}
