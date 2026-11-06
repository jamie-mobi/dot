//
//  InspectorView.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct InspectorView: View {
    // MARK: - Constants

    private enum Constants {
        static let mentionPage = 50
    }

    // MARK: - Environment

    @Environment(\.vaultService) private var vault
    @Environment(\.noteService) private var notes
    @Environment(\.linkService) private var links
    @Environment(\.navigationService) private var navigation
    @Environment(\.mentionService) private var mentions
    @Environment(\.indexService) private var index
    @Environment(\.searchService) private var search

    // MARK: - State

    @AppStorage("inspectorPane") private var pane = InspectorPane.backlinks
    @State private var pendingMention: UnlinkedMention?
    @State private var visibleMentions = Constants.mentionPage
    @State private var fileCreated: Date?
    @State private var fileModified: Date?

    // MARK: - View

    var body: some View {
        VStack(spacing: AppSpacing.comfortable) {
            Picker(String(localized: "Inspector"), selection: $pane) {
                ForEach(InspectorPane.allCases) { pane in
                    Text(pane.title).tag(pane)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, AppSpacing.comfortable)
            .onChange(of: pane) { _, pane in
                Usage.screen("inspector_\(pane.rawValue)")
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, AppSpacing.small)
        .onChange(of: notes.path) {
            visibleMentions = Constants.mentionPage
        }
        .task(id: MentionReload(path: notes.path, revision: index.revision)) {
            await mentions.load(for: notes.path)
        }
        .task(id: ReadingKey(path: notes.path ?? NotePath.root, revision: notes.path.flatMap(notes.document(for:))?.revision ?? 0)) {
            guard let path = notes.path else {
                return
            }

            fileCreated = await vault.store?.created(of: path)
            fileModified = await vault.store?.stamp(of: path)?.modified
        }
        .confirmationDialog(
            String(localized: "Link this mention?"),
            isPresented: Binding { pendingMention != nil } set: { if $0 == false { pendingMention = nil } },
            presenting: pendingMention
        ) { mention in
            Button(String(localized: "Link")) {
                Task { _ = await mentions.link(mention) }
            }
        } message: { mention in
            Text(String(localized: "Opal will change “\(mention.matchedText)” in \(mention.source.name) into a Link to \(notes.path?.name ?? ""). Nothing else in that Note changes."))
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let path = notes.path, notes.isReady {
            switch pane {
            case .backlinks:
                BacklinksView(
                    groups: BacklinkGroupUseCase.groups(links.map.backlinks(to: path)),
                    mentions: shownMentions(for: path),
                    mentionCount: mentions.target == path ? mentions.mentions.count : 0
                ) { source, line in
                    Task { await navigation.open(source, line: line) }
                } onOpenMention: { mention in
                    Task { await navigation.open(mention.source, line: mention.line) }
                } onLinkMention: { mention in
                    pendingMention = mention
                } onShowMoreMentions: {
                    visibleMentions += Constants.mentionPage
                }
            case .outgoing:
                OutgoingLinksView(links: links.map.outgoing(from: path, in: parsed(path))) { outgoing in
                    Task { await VaultActions.follow(outgoing.link, from: path, vault: vault, navigation: navigation) }
                }
            case .outline:
                outline(path)
            case .tags:
                NoteTagsView(tags: parsed(path).tags) { tag in
                    Usage.log("tag_opened")
                    search.show(query: TagTreeUseCase.searchQuery(forTag: tag))
                }
            }
        } else {
            ContentUnavailableView(String(localized: "No Note Open"), systemImage: "doc.text")
        }
    }

    // MARK: - Outline

    private func outline(_ path: NotePath) -> some View {
        let text = notes.document(for: path)?.loadState.note?.text ?? ""
        let stats = NoteStatsUseCase.stats(
            text: text,
            links: links.analysis(of: path)?.parsed.links.count ?? 0,
            backlinks: links.map.backlinks(to: path).count,
            fileCreated: fileCreated
        )
        return TimelineView(.periodic(from: .now, by: 60)) { context in
            OutlineView(
                headings: parsed(path).headings,
                currentLine: TextLineUseCase.line(atOffset: navigation.editorTopOffset, in: text),
                counts: NoteStatsText.counts(stats),
                dates: NoteStatsText.dates(stats, modified: fileModified, now: context.date)
            ) { heading in
                Task { await navigation.open(path, line: heading.line) }
            }
        }
    }

    // MARK: - Helpers

    private func shownMentions(for path: NotePath) -> [UnlinkedMention] {
        guard mentions.target == path else {
            return []
        }

        return Array(mentions.mentions.prefix(visibleMentions))
    }

    private func parsed(_ path: NotePath) -> ParsedNote {
        links.openNote.flatMap { $0.path == path ? $0.parsed : nil } ?? .empty
    }
}
