//
//  FolderTreeView.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct FolderTreeView: View {
    // MARK: - Binding

    @Binding var selection: NotePath?
    @Binding var expandedFolders: Set<NotePath>
    @Binding var renaming: NotePath?

    // MARK: - Input

    let vaultName: String
    let tree: [VaultTreeNode]
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
                    systemImage: "text.document",
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
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
            Text(vaultName)
                .lineLimit(1)
            Spacer()
            Text(String(localized: "\(noteCount) Notes"))
                .monospacedDigit()
        }
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
            vaultName: "Garden",
            tree: VaultTreeUseCase.tree(from: [
                VaultEntry(path: NotePath("Areas"), isFolder: true),
                VaultEntry(path: NotePath("Areas/Health.md"), isFolder: false),
                VaultEntry(path: NotePath("Attachments"), isFolder: true),
                VaultEntry(path: NotePath("Attachments/seedlings.png"), isFolder: false),
                VaultEntry(path: NotePath("Soil.md"), isFolder: false),
                VaultEntry(path: NotePath("A Note With A Very Long Name That Will Not Fit In The Sidebar.md"), isFolder: false)
            ])
        )
        .frame(width: 260, height: 400)
    }

    #Preview("Empty Vault") {
        @Previewable @State var selection: NotePath?
        @Previewable @State var expanded: Set<NotePath> = []
        FolderTreeView(selection: $selection, expandedFolders: $expanded, renaming: .constant(nil), vaultName: "New Vault", tree: [])
            .frame(width: 260, height: 400)
    }
#endif
