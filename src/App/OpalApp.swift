//
//  OpalApp.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

@main
struct OpalApp: App {
    // MARK: - Environment

    @NSApplicationDelegateAdaptor(OpalAppDelegate.self) private var appDelegate

    // MARK: - Scene

    var body: some Scene {
        WindowGroup(for: UUID.self) { $id in
            WindowScreen(id: id)
                .frame(minWidth: EditorMetrics.windowMinWidth, minHeight: EditorMetrics.windowMinHeight)
                .followsAccent()
                .containerBackground(for: .window) {
                    AppColor.window.background(.thinMaterial)
                }
                .defaultAppStorage(AppDependencies.shared.defaults)
        } defaultValue: {
            AppDependencies.shared.windows.defaultWindowID()
        }
        .defaultSize(width: EditorMetrics.windowDefaultWidth, height: EditorMetrics.windowDefaultHeight)
        .restorationBehavior(.disabled)
        .commands {
            OpalCommands(
                settings: AppDependencies.shared.settings,
                windows: AppDependencies.shared.windows,
                recents: AppDependencies.shared.recents,
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
