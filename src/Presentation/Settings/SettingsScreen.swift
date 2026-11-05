//
//  SettingsScreen.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import OpalDesign
import SwiftUI

struct SettingsScreen: View {
    // MARK: - State

    @AppStorage(EditorPreferences.settingsTabKey) private var tab = SettingsTab.general

    // MARK: - View

    var body: some View {
        TabView(selection: $tab) {
            ForEach(SettingsTab.allCases) { tab in
                content(tab)
                    .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                    .tag(tab)
            }
        }
        .onChange(of: tab, initial: true) { _, tab in
            Usage.screen("settings_\(tab.rawValue)")
        }
        .frame(width: EditorMetrics.settingsWidth)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Tabs

    @ViewBuilder
    private func content(_ tab: SettingsTab) -> some View {
        switch tab {
        case .general:
            GeneralSettingsView()
        case .editor:
            EditorSettingsView()
        case .filesAndLinks:
            FilesAndLinksSettingsView()
        case .dailyNotes:
            DailyNoteSettingsView()
        case .appearance:
            AppearanceSettingsView()
        case .shortcuts:
            ShortcutsSettingsView()
        }
    }
}
