//
//  VaultToolbar.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import SwiftUI

struct VaultToolbar: ToolbarContent {
    // MARK: - Environment

    @Environment(\.vaultService) private var vault
    @Environment(\.noteService) private var notes
    @Environment(\.navigationService) private var navigation

    // MARK: - Binding

    @Binding var homeLayout: HomeLayout
    @Binding var fileRequest: NoteFileRequest?

    // MARK: - Toolbar

    var body: some ToolbarContent {
        @Bindable var navigation = navigation
        ToolbarItemGroup(placement: .navigation) {
            Button(String(localized: "Back"), systemImage: "chevron.left") {
                Usage.feature(.back)
                Task { await navigation.goBack() }
            }
            .help(String(localized: "Go back (⌘[)"))
            .disabled(navigation.canGoBack == false)

            Button(String(localized: "Forward"), systemImage: "chevron.right") {
                Usage.feature(.forward)
                Task { await navigation.goForward() }
            }
            .help(String(localized: "Go forward (⌘])"))
            .disabled(navigation.canGoForward == false)
        }

        ToolbarItem(placement: .status) {
            SaveStatusItem()
        }

        ToolbarItemGroup(placement: .primaryAction) {
            switch navigation.destination {
            case .home,
                 .search:
                Picker(String(localized: "Layout"), selection: $homeLayout) {
                    ForEach(HomeLayout.allCases) { layout in
                        Label(layout.title, systemImage: layout.systemImage).tag(layout)
                    }
                }
                .pickerStyle(.segmented)
                .labelStyle(.titleAndIcon)
                .disabled(navigation.destination == .search)
                .help(String(localized: "Show Notes as cards or as a list"))

                Button(String(localized: "New Note"), systemImage: "plus") {
                    Usage.feature(.newNote)
                    Task { await VaultActions.createNote(vault: vault, navigation: navigation) }
                }
                .help(String(localized: "New Note (⌘N)"))
            case .note:
                Picker(String(localized: "Mode"), selection: $navigation.isReadingView) {
                    Label(String(localized: "Editing"), systemImage: "pencil").tag(false)
                    Label(String(localized: "Reading"), systemImage: "book").tag(true)
                }
                .pickerStyle(.segmented)
                .labelStyle(.titleAndIcon)
                .disabled(notes.path == nil)
                .help(String(localized: "Edit the Note, or read it without its Markdown (⌘E)"))

                Menu(String(localized: "More"), systemImage: "ellipsis") {
                    if let path = notes.path {
                        Button(String(localized: "Rename…")) {
                            fileRequest = .rename(path)
                        }
                        Button(String(localized: "Move…")) {
                            fileRequest = .move(path)
                        }
                        Button(String(localized: "Move to Trash")) {
                            fileRequest = .trash(path)
                        }
                    }
                }
                .disabled(notes.path == nil)
                .help(String(localized: "Rename, move or delete this Note"))

                Button(String(localized: "Toggle Inspector"), systemImage: "sidebar.right") {
                    Usage.feature(.toggleInspector)
                    navigation.isInspectorShown.toggle()
                }
                .help(String(localized: "Show or hide Backlinks and the outline (⌥⌘0)"))
            }
        }
    }
}
