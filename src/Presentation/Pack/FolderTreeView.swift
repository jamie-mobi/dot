//
//  FolderTreeView.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct FolderTreeView: View {
    // MARK: - Binding

    @Binding var selection: NotePath?
    @Binding var expandedFolders: Set<NotePath>
    @Binding var renaming: NotePath?

    // MARK: - Input

    let packName: String
    let tree: [PackTreeNode]
    var revealID = 0
    var noteCount = 0
    var starred: [NotePath] = []
    var recent: [RecentNote] = []
    var actions = FolderTreeActions()
    var openRecent: (NotePath) -> Void = { _ in }

    // MARK: - State

    @FocusState private var isFocused: Bool

    // MARK: - View

    var body: some View {
        ScrollViewReader { proxy in
            list
                .focused($isFocused)
                .onChange(of: revealID) {
                    reveal(with: proxy)
                }
        }
    }

    private var list: some View {
        List(selection: $selection) {
            if starred.isEmpty == false {
                Section(String(localized: "Starred")) {
                    ForEach(starred, id: \.self) { path in
                        StarredNoteRow(path: path) {
                            openRecent(path)
                        } onUnstar: {
                            actions.toggleStar(path)
                        }
                    }
                }
            }

            Section {
                ForEach(tree) { node in
                    FolderTreeRow(node: node, expandedFolders: $expandedFolders, renaming: $renaming, actions: actions)
                }
            } header: {
                header
            }

            if recent.isEmpty == false {
                Section(String(localized: "Recent Notes")) {
                    ForEach(recent) { note in
                        RecentNoteRow(note: note) {
                            openRecent(note.path)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .onDeleteCommand {
            if let selection {
                actions.delete(selection)
            }
        }
        .onKeyPress(.return) {
            guard renaming == nil, let selection else {
                return .ignored
            }
            renaming = selection
            return .handled
        }
        .overlay {
            if tree.isEmpty {
                ContentUnavailableView(
                    String(localized: "No Notes Yet"),
                    systemImage: "doc.text",
                    description: Text(String(localized: "Press ⌘N to write your first Note."))
                )
            }
        }
    }

    // MARK: - Reveal

    private func reveal(with proxy: ScrollViewProxy) {
        isFocused = true
        guard let selection else {
            return
        }

        Task {
            await Task.yield()
            proxy.scrollTo(FolderTreeRow.scrollID(for: selection), anchor: .center)
        }
    }

    // MARK: - Header

    private var header: some View {
        Text(packName)
            .lineLimit(1)
            .help(String(localized: "\(noteCount) Notes"))
    }
}

#if DEBUG
    #Preview("Garden") {
        @Previewable @State var selection: NotePath? = NotePath("Areas/Health.md")
        @Previewable @State var expanded: Set<NotePath> = [NotePath("Areas")]
        FolderTreeView(
            selection: $selection,
            expandedFolders: $expanded,
            renaming: .constant(nil),
            packName: "Garden",
            tree: PackTreeUseCase.tree(from: [
                PackEntry(path: NotePath("Areas"), isFolder: true),
                PackEntry(path: NotePath("Areas/Health.md"), isFolder: false),
                PackEntry(path: NotePath("Attachments"), isFolder: true),
                PackEntry(path: NotePath("Attachments/seedlings.png"), isFolder: false),
                PackEntry(path: NotePath("Soil.md"), isFolder: false),
                PackEntry(path: NotePath("A Note With A Very Long Name That Will Not Fit In The Sidebar.md"), isFolder: false)
            ])
        )
        .frame(width: 260, height: 400)
    }

    #Preview("Empty Pack") {
        @Previewable @State var selection: NotePath?
        @Previewable @State var expanded: Set<NotePath> = []
        FolderTreeView(selection: $selection, expandedFolders: $expanded, renaming: .constant(nil), packName: "New Pack", tree: [])
            .frame(width: 260, height: 400)
    }
#endif
