//
//  DotCommands.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import SwiftUI

struct DotCommands: Commands {
    // MARK: - Environment

    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @FocusedValue(\.serviceGraph) private var focusedGraph
    @FocusedValue(\.windowID) private var windowID

    // MARK: - Dependencies

    let settings: SettingsService
    let windows: WindowRegistry
    let recents: RecentPacksService
    let updates: UpdateService
    let placeholder: ServiceGraph

    // MARK: - Preferences

    @AppStorage private var isLiveMarkdown: Bool

    // MARK: - Init

    init(settings: SettingsService, windows: WindowRegistry, recents: RecentPacksService, updates: UpdateService, placeholder: ServiceGraph, defaults: UserDefaults) {
        self.settings = settings
        self.windows = windows
        self.recents = recents
        self.updates = updates
        self.placeholder = placeholder
        _isLiveMarkdown = AppStorage(wrappedValue: true, EditorPreferences.liveMarkdownKey, store: defaults)
    }

    // MARK: - Runner

    private var graph: ServiceGraph? {
        focusedGraph ?? windows.activeGraph
    }

    private var currentWindowID: UUID? {
        focusedGraph == nil ? windows.activeWindowID : windowID
    }

    private var navigation: NavigationService {
        (graph ?? placeholder).navigation
    }

    private var runner: AppCommandRunner {
        AppCommandRunner(
            graph: graph ?? placeholder,
            windowID: graph == nil ? nil : currentWindowID,
            windows: windows,
            shortcuts: settings.settings.shortcuts,
            toggleLiveMarkdown: { isLiveMarkdown.toggle() },
            openSettings: { openSettings() },
            openWindow: { openWindow(value: $0) },
            closeWindow: { dismissWindow(value: $0) }
        )
    }

    private var liveMarkdownBinding: Binding<Bool> {
        Binding {
            isLiveMarkdown
        } set: { isOn in
            Usage.feature(.toggleLiveMarkdown)
            isLiveMarkdown = isOn
        }
    }

    // MARK: - Commands

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button(String(localized: "Check for Updates…")) {
                updates.checkForUpdates()
            }
            .disabled(updates.canCheckForUpdates == false)
        }

        CommandGroup(replacing: .appSettings) {
            runner.button(.settings)
        }

        CommandGroup(replacing: .newItem) {
            runner.button(.newWindow)
            Divider()
            runner.button(.newNote)
            runner.button(.newTab)
            runner.button(.duplicateNote)
            runner.button(.toggleStar, title: starTitle)
            runner.button(.newFolder)
            Divider()
            runner.button(.openPack)
            runner.button(.openNote)
            openRecentMenu
            runner.button(.createPack)
        }

        CommandGroup(after: .pasteboard) {
            Divider()
            runner.button(.insertTemplate)
        }

        CommandMenu(String(localized: "Go")) {
            runner.button(.commandPalette)
            Divider()
            runner.button(.quickSwitcher)
            runner.button(.dailyNote)
            runner.button(.searchPack)
            runner.button(.home)
            runner.button(.revealInFolderTree)
            Divider()
            runner.button(.back)
            runner.button(.forward)
            Divider()
            runner.button(.nextTab)
            runner.button(.previousTab)
        }

        CommandGroup(after: .sidebar) {
            runner.button(.toggleReadingView, title: navigation.isReadingView ? String(localized: "Editor") : String(localized: "Reading View"))
            Toggle(String(localized: "Live Markdown"), isOn: liveMarkdownBinding)
                .keyboardShortcut(runner.keyboardShortcut(.toggleLiveMarkdown))
            Divider()
            runner.button(.splitRight)
            runner.button(.toggleInspector)
        }

        CommandGroup(replacing: .saveItem) {
            runner.button(.closeTab)
            runner.button(.save)
            runner.button(.reloadPack)
        }
    }

    // MARK: - Star

    private var starTitle: String {
        guard let path = graph?.notes.path, graph?.stars.isStarred(path) == true else {
            return String(localized: "Star Note")
        }

        return String(localized: "Unstar Note")
    }

    // MARK: - Open Recent

    private var openRecentMenu: some View {
        Menu(String(localized: "Open Recent")) {
            ForEach(recents.packs) { pack in
                Button {
                    openRecent(pack)
                } label: {
                    Text(pack.name)
                    Text(pack.isMissing ? String(localized: "Folder not found") : pack.shortParentPath)
                }
                .disabled(pack.isMissing)
            }
            Divider()
            Button(String(localized: "Clear Menu")) {
                Task { await recents.clear() }
            }
            .disabled(recents.packs.isEmpty)
        }
        .disabled(runner.isEnabled(.openPack) == false)
    }

    private func openRecent(_ pack: RecentPack) {
        guard let graph, let windowID = currentWindowID else {
            return
        }

        Task {
            await PackActions.openRecent(pack, recents: recents, graph: graph, windowID: windowID, windows: windows, openWindow: { openWindow(value: $0) }, closeWindow: { dismissWindow(value: $0) })
        }
    }
}
