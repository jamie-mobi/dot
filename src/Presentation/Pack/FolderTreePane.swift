//
//  FolderTreePane.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct FolderTreePane: View {
    // MARK: - Environment

    @Environment(\.packService) private var packService
    @Environment(\.renameService) private var renamer
    @Environment(\.launchRequest) private var launch
    @Environment(\.navigationService) private var navigation
    @Environment(\.folderColourService) private var folderColours
    @Environment(\.starredNoteService) private var stars

    // MARK: - Input

    @Binding var selection: NotePath?
    @Binding var expandedFolders: Set<NotePath>
    @Binding var request: NoteFileRequest?
    let packName: String
    var revealID = 0

    // MARK: - State

    @State private var renaming: NotePath?
    @State private var pending: PendingRename?
    @State private var problem: String?
    @State private var moving: MoveRequest?
    @State private var deleting: MoveRequest?
    @State private var recent: [RecentNote] = []

    // MARK: - View

    var body: some View {
        FolderTreeView(
            selection: $selection,
            expandedFolders: $expandedFolders,
            renaming: $renaming,
            packName: packName,
            tree: packService.tree,
            revealID: revealID,
            noteCount: noteCount,
            starred: starred,
            recent: recent,
            actions: FolderTreeActions(
                reveal: { PackActions.reveal($0, pack: packService) },
                openInDefaultApp: { PackActions.openInDefaultApp($0, pack: packService) },
                rename: rename,
                move: move,
                chooseFolder: { moving = MoveRequest(path: $0) },
                duplicate: { path in Task { await PackActions.duplicate(path, pack: packService, navigation: navigation) } },
                delete: { deleting = MoveRequest(path: $0) },
                openInNewTab: { path in
                    Usage.feature(.newTab)
                    Task { await navigation.openInNewTab(path) }
                },
                toggleStar: { path in
                    Usage.feature(.toggleStar)
                    Task { await stars.toggle(path) }
                },
                isStarred: { stars.isStarred($0) },
                folderColour: { folderColours.ownColour(of: $0) },
                setFolderColour: { colour, folder in Task { await folderColours.set(colour, for: folder) } }
            )
        ) { path in
            Task { await navigation.open(path) }
        }
        .task {
            await stars.load()
            await folderColours.load()
            await navigation.loadRecentNotes()
        }
        .task(id: RecentKey(paths: navigation.recentNotes, revision: packService.entriesRevision)) {
            await loadRecent()
        }
        .onChange(of: request) { _, request in
            handle(request)
        }
        .sheet(item: $moving) { request in
            MoveToFolderView(item: request.path, folders: folders, packName: packName) { folder in
                move(request.path, into: folder)
            }
        }
        .task {
            if let path = launch.renaming {
                try? await Task.sleep(for: .seconds(1))
                renaming = path
            }
            if let path = launch.deleting {
                try? await Task.sleep(for: .seconds(1))
                deleting = MoveRequest(path: path)
            }
            if let path = launch.moving {
                try? await Task.sleep(for: .seconds(1))
                moving = MoveRequest(path: path)
            }
        }
        .confirmationDialog(
            String(localized: "Update Links in \(pending?.plan.linkingNotes.count ?? 0) Notes?"),
            isPresented: Binding { pending != nil } set: { if $0 == false { pending = nil } },
            presenting: pending
        ) { pending in
            Button(String(localized: "Update Links")) {
                perform(pending, updatingLinks: true)
            }
            Button(String(localized: "Don't Update")) {
                perform(pending, updatingLinks: false)
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: { pending in
            Text(String(localized: "Other Notes link to “\(pending.path.name)”. Dot can change those Links to the new name. Nothing else in those Notes changes."))
        }
        .alert(
            String(localized: "Move “\(deleting?.path.name ?? "")” to the Trash?"),
            isPresented: Binding { deleting != nil } set: { if $0 == false { deleting = nil } },
            presenting: deleting
        ) { request in
            Button(String(localized: "Move to Trash"), role: .destructive) {
                trash(request.path)
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: { request in
            Text(deleteMessage(for: request.path))
        }
        .alert(
            String(localized: "Dot Couldn't Make That Change"),
            isPresented: Binding { problem != nil } set: { if $0 == false { problem = nil } }
        ) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(problem ?? "")
        }
    }

    // MARK: - Recent Notes

    private var starred: [NotePath] {
        stars.notes.filter { packService.kind(of: $0) == .note }
    }

    private var noteCount: Int {
        packService.entries.count { $0.kind == .note }
    }

    private func loadRecent() async {
        let now = Date.now
        var loaded: [RecentNote] = []
        for path in navigation.recentNotes.prefix(EditorMetrics.recentNotesShown) where packService.kind(of: path) == .note {
            let stamp = await packService.store?.stamp(of: path)
            loaded.append(RecentNote(path: path, age: stamp.map { RelativeAgeUseCase.age(of: $0.modified, now: now) }))
        }
        recent = loaded
    }

    // MARK: - Folders

    private var folders: [NotePath] {
        packService.entries
            .filter { $0.kind == .folder }
            .map(\.path)
            .sorted { $0.rawValue.localizedStandardCompare($1.rawValue) == .orderedAscending }
    }

    // MARK: - Intent

    private func handle(_ request: NoteFileRequest?) {
        switch request {
        case let .rename(path):
            expandedFolders.formUnion(path.ancestors)
            selection = path
            renaming = path
        case let .move(path):
            moving = MoveRequest(path: path)
        case let .trash(path):
            deleting = MoveRequest(path: path)
        case nil:
            return
        }
        self.request = nil
    }

    private func rename(_ path: NotePath, to name: String) {
        switch renamer.plan(renaming: path, to: name) {
        case let .success(plan) where plan.linkingNotes.isEmpty:
            perform(PendingRename(path: path, plan: plan), updatingLinks: false)
        case let .success(plan):
            confirm(PendingRename(path: path, plan: plan))
        case .failure(.unchanged):
            break
        case let .failure(failure):
            problem = failure.message
        }
    }

    private func move(_ path: NotePath, into folder: NotePath) {
        switch renamer.plan(moving: path, into: folder) {
        case let .success(plan) where plan.linkingNotes.isEmpty:
            perform(PendingRename(path: path, plan: plan), updatingLinks: true)
        case let .success(plan):
            confirm(PendingRename(path: path, plan: plan))
        case .failure(.sameFolder), .failure(.unchanged):
            break
        case let .failure(failure):
            problem = failure.message
        }
    }

    private func deleteMessage(for path: NotePath) -> String {
        guard packService.kind(of: path) == .folder else {
            return String(localized: "You can get it back from the Trash. Links to it will show as Unresolved.")
        }

        return String(localized: "The Folder and the \(renamer.notesInside(path)) Notes in it go to the Trash. You can get them back from there.")
    }

    private func trash(_ path: NotePath) {
        Task {
            do throws(PackError) {
                try await renamer.trash(path)
                Usage.log("note_deleted")
                if let current = selection, current.components.starts(with: path.components) {
                    selection = nil
                }
            } catch {
                problem = error.message
            }
        }
    }

    private func confirm(_ rename: PendingRename) {
        switch packService.linkUpdate {
        case .ask:
            pending = rename
        case .always:
            perform(rename, updatingLinks: true)
        case .never:
            perform(rename, updatingLinks: false)
        }
    }

    private func perform(_ pending: PendingRename, updatingLinks: Bool) {
        Task {
            do throws(PackError) {
                let renamed = try await renamer.perform(pending.plan, from: pending.path, updatingLinks: updatingLinks)
                Usage.log(
                    pending.path.parent == renamed.parent ? "note_renamed" : "note_moved",
                    ["links_updated": String(updatingLinks), "linking_notes": Usage.countBucket(pending.plan.linkingNotes.count)]
                )
                expandedFolders = Set(expandedFolders.map { $0.replacingPrefix(pending.path, with: renamed) })
                if let current = selection {
                    selection = current.replacingPrefix(pending.path, with: renamed)
                }
            } catch {
                problem = error.message
            }
        }
    }
}
