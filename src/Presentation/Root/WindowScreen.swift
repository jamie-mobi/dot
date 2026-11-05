//
//  WindowScreen.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import OpalCore
import SwiftUI

struct WindowScreen: View {
    // MARK: - Environment

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.appearsActive) private var appearsActive

    // MARK: - Input

    let id: UUID

    // MARK: - Derived

    private var app: AppGraph {
        AppDependencies.shared
    }

    private var isFirst: Bool {
        id == app.windows.firstWindowID
    }

    // MARK: - View

    var body: some View {
        let graph = app.windows.graph(for: id)
        RootScreen()
            .serviceGraph(graph)
            .environment(\.windowID, id)
            .environment(\.launchRequest, isFirst ? app.launchRequest : LaunchRequest())
            .focusedSceneValue(\.serviceGraph, graph)
            .focusedSceneValue(\.windowID, id)
            .remembersWindowFrame(id: id, restores: app.restoresState && app.launchSnapshotURL == nil)
            .onChange(of: appearsActive, initial: true) { _, isActive in
                if isActive {
                    graph.settings.activate(graph.vault)
                }
            }
            .task {
                guard isFirst, app.restoresState, app.launchSnapshotURL == nil else {
                    return
                }

                for other in app.windows.restoredIDs where other != id {
                    openWindow(value: other)
                }
            }
            .onChange(of: graph.vault.isOpen) { _, isOpen in
                guard isOpen else {
                    return
                }

                for welcome in app.windows.welcomeWindows(besides: id) {
                    dismissWindow(value: welcome)
                }
            }
            .onDisappear {
                Task { await app.windows.close(id) }
            }
    }
}
