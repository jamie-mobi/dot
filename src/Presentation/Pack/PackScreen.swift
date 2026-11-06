//
//  PackScreen.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct PackScreen: View {
    // MARK: - Environment

    @Environment(\.packService) private var packService
    @Environment(\.noteService) private var notes
    @Environment(\.navigationService) private var navigation

    // MARK: - State

    @SceneStorage("homeLayout") private var homeLayout = HomeLayout.cards
    @State private var selection: NotePath?
    @State private var attachment: NotePath?
    @State private var expandedFolders: Set<NotePath> = []
    @State private var columns = NavigationSplitViewVisibility.all
    @State private var openNoteModified: Date?
    @State private var fileRequest: NoteFileRequest?

    // MARK: - Input

    let pack: Pack

    // MARK: - View

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            FolderTreePane(selection: $selection, expandedFolders: $expandedFolders, request: $fileRequest, packName: pack.name, revealID: navigation.folderTreeReveal)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    IndexStatusItem()
                }
                .navigationSplitViewColumnWidth(EditorMetrics.sidebarWidth)
        } detail: {
            detail
                .background(AppColor.editorBackground)
                .inspector(isPresented: inspectorShown) {
                    InspectorView()
                        .inspectorColumnWidth(EditorMetrics.inspectorWidth)
                }
        }
        .navigationTitle(title)
        .navigationSubtitle(subtitle)
        .toolbar {
            PackToolbar(homeLayout: $homeLayout, fileRequest: $fileRequest)
        }
        .overlay {
            PackOverlayView()
        }
        .frame(
            minWidth: EditorMetrics.windowMinWidth,
            idealWidth: EditorMetrics.windowDefaultWidth,
            minHeight: EditorMetrics.windowMinHeight,
            idealHeight: EditorMetrics.windowDefaultHeight
        )
        .task(id: ReadingKey(path: notes.path ?? NotePath.root, revision: notes.path.flatMap(notes.document(for:))?.revision ?? 0)) {
            guard let path = notes.path else {
                openNoteModified = nil
                return
            }

            openNoteModified = await packService.store?.stamp(of: path)?.modified
        }
        .onChange(of: selection) { _, newSelection in
            guard let newSelection else {
                return
            }

            switch packService.kind(of: newSelection) {
            case .note:
                attachment = nil
                Task { await navigation.open(newSelection) }
            case .attachment:
                attachment = newSelection
            case .folder,
                 nil:
                break
            }
        }
        .onChange(of: navigation.destination) {
            attachment = nil
        }
        .onChange(of: navigation.isReadingView) { _, isReading in
            Usage.screen(isReading ? "reading_view" : "editor")
        }
        .onChange(of: navigation.destination, initial: true) { _, destination in
            Usage.screen("pack_\(destination.rawValue)")
        }
        .background(PackSync())
        .onChange(of: notes.path) { _, openPath in
            guard let openPath else {
                return
            }

            attachment = nil
            expandedFolders.formUnion(openPath.ancestors)
            selection = openPath
        }
        .onChange(of: navigation.folderTreeReveal) {
            guard let openPath = notes.path else {
                return
            }

            columns = .all
            expandedFolders.formUnion(openPath.ancestors)
            selection = openPath
        }
    }

    // MARK: - Detail

    @ViewBuilder
    private var detail: some View {
        if let attachment {
            AttachmentView(name: attachment.fileName) {
                PackActions.openInDefaultApp(attachment, pack: packService)
            }
        } else {
            switch navigation.destination {
            case .home:
                HomeScreen(packName: pack.name, layout: homeLayout)
            case .search:
                SearchScreen(packName: pack.name)
            case .note where showsHome:
                HomeScreen(packName: pack.name, layout: homeLayout)
            case .note:
                SplitPanesView(isSplit: navigation.panes.isSplit) {
                    editorPane(0)
                } second: {
                    editorPane(1)
                }
            }
        }
    }

    private var showsHome: Bool {
        notes.path == nil && navigation.panes.isSplit == false && navigation.tabs.tabs.count <= 1
    }

    private var inspectorShown: Binding<Bool> {
        Binding {
            navigation.isInspectorShown && navigation.destination == .note && showsHome == false && attachment == nil
        } set: { isShown in
            navigation.isInspectorShown = isShown
        }
    }

    private func editorPane(_ pane: Int) -> some View {
        NoteScreen(pane: pane)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                if navigation.panes.isSplit || navigation.tabs.tabs.count > 1 {
                    VStack(spacing: 0) {
                        TabBarView(pane: pane)
                        Divider()
                    }
                }
            }
    }

    // MARK: - Title

    private var title: String {
        switch navigation.destination {
        case .home:
            pack.name
        case .search:
            String(localized: "Search")
        case .note:
            WindowTitleUseCase.title(packName: pack.name, openNote: showsHome ? nil : notes.path)
        }
    }

    private var subtitle: String {
        switch navigation.destination {
        case .home:
            noteCountText
        case .search:
            pack.name
        case .note where showsHome:
            noteCountText
        case .note:
            noteSubtitle
        }
    }

    private var noteCountText: String {
        let count = packService.entries.count { $0.kind == .note }
        return count == 1 ? String(localized: "1 Note") : String(localized: "\(count) Notes")
    }

    private var noteSubtitle: String {
        guard let path = notes.path else {
            return ""
        }

        let location = path.parent.isRoot ? pack.name : path.parent.rawValue
        guard let modified = openNoteModified else {
            return location
        }

        return "\(location) · \(RelativeAgeUseCase.age(of: modified, now: .now).editedText(for: modified))"
    }
}
