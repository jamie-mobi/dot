//
//  RootScreen.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct RootScreen: View {
    // MARK: - Environment

    @Environment(\.packService) private var pack
    @Environment(\.noteService) private var notes
    @Environment(\.navigationService) private var navigation
    @Environment(\.quickSwitcherService) private var switcher
    @Environment(\.searchService) private var search
    @Environment(\.launchRequest) private var launch
    @Environment(\.dailyNoteService) private var dailyNotes
    @Environment(\.templateService) private var templates
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.serviceGraph) private var graph
    @Environment(\.windowID) private var windowID

    // MARK: - Preferences

    @AppStorage(EditorPreferences.appearanceKey) private var appearance = AppearanceChoice.system
    @AppStorage(EditorPreferences.settingsTabKey) private var settingsTab = SettingsTab.editor

    // MARK: - View

    var body: some View {
        content
            .onChange(of: appearance, initial: true) { _, choice in
                if AppDependencies.shared.launchAppearance == nil {
                    NSApp.appearance = choice.appearance
                }
            }
            .task {
                await AppDependencies.shared.recents.load()
                for url in launch.recentPacks {
                    await AppDependencies.shared.recents.record(url)
                }
                await pack.start()
                if let windowID, let waiting = AppDependencies.shared.windows.takeWaitingPack(for: windowID) {
                    await PackActions.open(waiting, in: graph)
                }
                if pack.isOpen, AppDependencies.shared.restoresState {
                    await navigation.restoreWindowState()
                }
                if let note = launch.note, pack.isOpen {
                    await navigation.open(note)
                    if launch.editsAsYAML {
                        navigation.unfoldFrontmatter(of: note)
                        await navigation.open(note, line: 1)
                    }
                }
                for tab in launch.extraTabs where pack.isOpen {
                    await navigation.openInNewTab(tab)
                }
                if let split = launch.splitNote, pack.isOpen {
                    await navigation.splitRight()
                    await navigation.open(split)
                    if let share = launch.splitShare {
                        navigation.setSplitShare(share)
                    }
                }
                if launch.opensNewWindow {
                    openWindow(value: AppDependencies.shared.windows.newWindow())
                }
                if let tab = launch.settingsTab.flatMap(SettingsTab.init(rawValue:)) {
                    settingsTab = tab
                    openSettings()
                }
                if launch.opensDailyNote, pack.isOpen {
                    await dailyNotes.openToday()
                }
                if launch.showsCommandPalette || launch.showsTemplates, pack.isOpen {
                    try? await Task.sleep(for: .seconds(1))
                    navigation.isCommandPaletteShown = launch.showsCommandPalette
                    if launch.showsTemplates {
                        templates.showPicker()
                    }
                }
                if launch.isReadingView {
                    navigation.isReadingView = true
                }
                if launch.hidesInspector {
                    navigation.isInspectorShown = false
                }
                if let query = launch.search, pack.isOpen {
                    search.show(query: query)
                }
                if let switcherQuery = launch.quickOpen, pack.isOpen {
                    await PackActions.showQuickSwitcher(query: switcherQuery, switcher: switcher, navigation: navigation)
                }
            }
    }

    // MARK: - Load state

    @ViewBuilder
    private var content: some View {
        switch pack.loadState {
        case let .closed(reason):
            let recents = AppDependencies.shared.recents
            WelcomeScreen(message: reason?.message, recents: recents.packs) {
                Task { await PackActions.openPack(graph: graph, windowID: windowID, windows: AppDependencies.shared.windows, openWindow: { openWindow(value: $0) }, closeWindow: { dismissWindow(value: $0) }) }
            } onCreate: {
                Task { await PackActions.createPack(graph: graph, windowID: windowID, windows: AppDependencies.shared.windows, openWindow: { openWindow(value: $0) }, closeWindow: { dismissWindow(value: $0) }) }
            } onChoose: { recent in
                Task { await PackActions.openRecent(recent, recents: recents, graph: graph, windowID: windowID, windows: AppDependencies.shared.windows, openWindow: { openWindow(value: $0) }, closeWindow: { dismissWindow(value: $0) }) }
            } onRemove: { recent in
                Task { await recents.remove(recent) }
            }
            .task { await recents.load() }
        case .opening:
            ProgressView(String(localized: "Opening Pack…"))
                .frame(width: EditorMetrics.welcomeWidth, height: EditorMetrics.welcomeHeight)
        case let .open(openPack):
            PackScreen(pack: openPack)
        }
    }
}

#if DEBUG
    #Preview("No Pack") {
        let graph = PreviewGraph.makeGraph(openingGarden: false)
        RootScreen()
            .serviceGraph(graph)
    }

    #Preview("Garden Pack") {
        let graph = PreviewGraph.makeGraph(openingGarden: true)
        RootScreen()
            .serviceGraph(graph)
    }
#endif
