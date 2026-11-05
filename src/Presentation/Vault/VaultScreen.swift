//
//  VaultScreen.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct VaultScreen: View {
    // MARK: - Environment

    @Environment(\.vaultService) private var vaultService
    @Environment(\.noteService) private var notes
    @Environment(\.linkService) private var links
    @Environment(\.searchService) private var search
    @Environment(\.navigationService) private var navigation
    @Environment(\.dailyNoteService) private var dailyNotes
    @Environment(\.templateService) private var templates

    // MARK: - State

    @State private var selection: NotePath?
    @State private var expandedFolders: Set<NotePath> = []
    @State private var columns = NavigationSplitViewVisibility.all
    @State private var openNoteModified: Date?

    // MARK: - Input

    let vault: Vault

    // MARK: - View

    var body: some View {
        @Bindable var navigation = navigation
        @Bindable var templates = templates
        NavigationSplitView(columnVisibility: $columns) {
            sidebar
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    IndexStatusItem()
                }
                .navigationSplitViewColumnWidth(min: EditorMetrics.sidebarMinWidth, ideal: EditorMetrics.sidebarIdealWidth)
        } detail: {
            detail
                .clipShape(.rect(cornerRadius: AppRadius.sidebar))
                .padding(AppSpacing.small)
                .inspector(isPresented: $navigation.isInspectorShown) {
                    InspectorView()
                        .inspectorColumnWidth(
                            min: EditorMetrics.inspectorMinWidth,
                            ideal: EditorMetrics.inspectorIdealWidth,
                            max: EditorMetrics.inspectorMaxWidth
                        )
                }
        }
        .navigationTitle(WindowTitleUseCase.title(vaultName: vault.name, openNote: notes.path))
        .navigationSubtitle(subtitle)
        .task(id: ReadingKey(path: notes.path ?? NotePath.root, revision: notes.path.flatMap(notes.document(for:))?.revision ?? 0)) {
            guard let path = notes.path else {
                openNoteModified = nil
                return
            }

            openNoteModified = await vaultService.store?.stamp(of: path)?.modified
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    Usage.feature(.back)
                    Task { await navigation.goBack() }
                } label: {
                    Label(String(localized: "Back"), systemImage: "chevron.backward")
                }
                .help(String(localized: "Go back (⌘[)"))
                .disabled(navigation.history.canGoBack == false)

                Button {
                    Usage.feature(.forward)
                    Task { await navigation.goForward() }
                } label: {
                    Label(String(localized: "Forward"), systemImage: "chevron.forward")
                }
                .help(String(localized: "Go forward (⌘])"))
                .disabled(navigation.history.canGoForward == false)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    Usage.feature(.dailyNote)
                    Task { await dailyNotes.openToday() }
                } label: {
                    Label(String(localized: "Today's Daily Note"), systemImage: "calendar")
                }
                .help(String(localized: "Open today's Daily Note (⌥⌘D)"))
            }

            ToolbarItem(placement: .status) {
                SaveStatusItem()
            }

            ToolbarItem(placement: .primaryAction) {
                Picker(String(localized: "Mode"), selection: $navigation.isReadingView) {
                    Text(String(localized: "Editing")).tag(false)
                    Text(String(localized: "Reading")).tag(true)
                }
                .pickerStyle(.segmented)
                .help(String(localized: "Edit the Note, or read it without its Markdown (⌘E)"))
                .disabled(notes.path == nil)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    Usage.feature(.toggleInspector)
                    navigation.isInspectorShown.toggle()
                } label: {
                    Label(String(localized: "Inspector"), systemImage: "sidebar.trailing")
                }
                .help(String(localized: "Show or hide Backlinks and the outline (⌥⌘0)"))
            }
        }
        .onChange(of: selection) { _, newSelection in
            guard let newSelection, vaultService.kind(of: newSelection) == .note else {
                return
            }

            Task { await navigation.open(newSelection) }
        }
        .sheet(isPresented: $navigation.isQuickSwitcherShown) {
            QuickSwitcherView()
        }
        .sheet(isPresented: $templates.isPickerShown) {
            TemplatePickerView()
        }
        .sheet(isPresented: $navigation.isCommandPaletteShown) {
            CommandPaletteView()
        }
        .background(VaultSync())
        .onChange(of: notes.path) { _, openPath in
            guard let openPath else {
                return
            }

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

    // MARK: - Sidebar

    private var sidebar: some View {
        @Bindable var navigation = navigation
        return VStack(spacing: 0) {
            Picker(String(localized: "Sidebar"), selection: $navigation.sidebarPane) {
                ForEach(SidebarPane.allCases) { pane in
                    Label(pane.title, systemImage: pane.systemImage)
                        .labelStyle(.iconOnly)
                        .help(pane.title)
                        .tag(pane)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, AppSpacing.small)
            .padding(.bottom, AppSpacing.xsmall)
            .onChange(of: navigation.sidebarPane) { _, pane in
                Usage.screen("sidebar_\(pane.rawValue)")
            }
            .onChange(of: navigation.isReadingView) { _, isReading in
                Usage.screen(isReading ? "reading_view" : "editor")
            }

            switch navigation.sidebarPane {
            case .files:
                folderTree
            case .search:
                SearchView()
            case .tags:
                TagsView(tags: links.map.tags) { tag in
                    Usage.log("tag_opened")
                    search.show(query: TagTreeUseCase.searchQuery(for: tag))
                }
            }
        }
    }

    private var folderTree: some View {
        FolderTreePane(selection: $selection, expandedFolders: $expandedFolders, vaultName: vault.name, revealID: navigation.folderTreeReveal)
    }

    // MARK: - Title

    private var subtitle: String {
        let base = WindowTitleUseCase.subtitle(vaultName: vault.name, openNote: notes.path)
        guard notes.path != nil, let modified = openNoteModified else {
            return base
        }

        return "\(base) · \(RelativeAgeUseCase.age(of: modified, now: .now).editedText(for: modified))"
    }

    // MARK: - Detail

    private var showsHome: Bool {
        notes.path == nil && navigation.panes.isSplit == false && navigation.tabs.tabs.count <= 1
    }

    @ViewBuilder
    private var detail: some View {
        switch DetailContentUseCase.content(selection: selection, kind: selection.flatMap(vaultService.kind(of:))) {
        case .note where showsHome:
            VaultHomeView()
        case .note:
            SplitPanesView(isSplit: navigation.panes.isSplit) {
                editorPane(0)
            } second: {
                editorPane(1)
            }
        case let .attachment(path):
            AttachmentView(name: path.fileName) {
                VaultActions.openInDefaultApp(path, vault: vaultService)
            }
        }
    }

    private func editorPane(_ pane: Int) -> some View {
        NoteScreen(pane: pane)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                if navigation.panes.isSplit || notes.path != nil || navigation.tabs.tabs.count > 1 {
                    VStack(spacing: 0) {
                        TabBarView(pane: pane)
                        Divider()
                    }
                }
            }
    }
}

#if DEBUG
    #Preview {
        let graph = PreviewGraph.makeGraph(openingGarden: true)
        VaultScreen(vault: Vault(rootURL: PreviewGraph.gardenRoot))
            .serviceGraph(graph)
            .task { await graph.vault.start() }
    }
#endif
