//
//  VaultHomeView.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct VaultHomeView: View {
    // MARK: - Environment

    @Environment(\.serviceGraph) private var graph
    @Environment(\.navigationService) private var navigation
    @Environment(\.searchService) private var search
    @Environment(\.folderColourService) private var folderColours
    @Environment(\.indexService) private var index
    @Environment(\.linkService) private var links

    // MARK: - State

    @SceneStorage("homeLayout") private var layout = HomeLayout.cards
    @State private var query = ""
    @FocusState private var focused: NotePath?

    // MARK: - Derived

    private var home: VaultHome {
        graph.home.home
    }

    private var order: [NotePath] {
        home.recent.map(\.path) + home.groups.flatMap { $0.cards.map(\.path) }
    }

    // MARK: - View

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.wide) {
                    searchField
                    if home.recent.isEmpty {
                        ContentUnavailableView(
                            String(localized: "No Notes Yet"),
                            systemImage: "text.document",
                            description: Text(String(localized: "Press ⌘N to write your first Note."))
                        )
                    } else {
                        section(title: String(localized: "Recently edited"), count: home.recent.count, colour: nil, cards: home.recent, now: context.date, showsSwitch: true)
                        ForEach(home.groups) { group in
                            section(title: group.folder.name, count: group.noteCount, colour: colour(of: group.folder), cards: group.cards, now: context.date, showsSwitch: false)
                        }
                    }
                }
                .frame(maxWidth: EditorMetrics.homeMaxWidth)
                .padding(AppSpacing.large)
                .frame(maxWidth: .infinity)
            }
        }
        .background(AppColor.editorBackground)
        .onMoveCommand(perform: move)
        .task(id: HomeKey(index: index.revision, links: links.mapRevision)) {
            await graph.home.refresh()
        }
    }

    // MARK: - Search

    private var searchField: some View {
        TextField(String(localized: "Search Notes"), text: $query, prompt: Text(String(localized: "Search Notes  ⇧⌘F")))
            .textFieldStyle(.plain)
            .padding(.horizontal, AppSpacing.regular)
            .padding(.vertical, AppSpacing.comfortable)
            .background(AppColor.surface, in: .rect(cornerRadius: AppRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .strokeBorder(Color(nsColor: .separatorColor))
            }
            .frame(maxWidth: EditorMetrics.homeSearchWidth)
            .frame(maxWidth: .infinity)
            .onSubmit {
                Usage.feature(.searchVault)
                search.show(query: query)
            }
    }

    // MARK: - Sections

    private func section(title: String, count: Int, colour: Color?, cards: [NoteCard], now: Date, showsSwitch: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.regular) {
            HStack(spacing: AppSpacing.small) {
                if let colour {
                    Circle()
                        .fill(colour)
                        .frame(width: EditorMetrics.labelDotSize, height: EditorMetrics.labelDotSize)
                }
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(String(localized: "\(count) Notes"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                if showsSwitch {
                    Picker(String(localized: "Layout"), selection: $layout) {
                        ForEach(HomeLayout.allCases) { choice in
                            Label(choice.title, systemImage: choice.systemImage).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .fixedSize()
                }
            }

            switch layout {
            case .cards:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: EditorMetrics.cardMinWidth), spacing: AppSpacing.regular)], spacing: AppSpacing.regular) {
                    ForEach(cards) { card in
                        item(card) {
                            NoteCardView(card: card, colour: cardColour(card.path), label: label(of: card), now: now, isFocused: focused == card.path)
                        }
                    }
                }
            case .list:
                VStack(spacing: AppSpacing.tiny) {
                    ForEach(cards) { card in
                        item(card) {
                            NoteCardRow(card: card, colour: cardColour(card.path), label: label(of: card), now: now, isFocused: focused == card.path)
                        }
                    }
                }
            }
        }
    }

    private func item(_ card: NoteCard, @ViewBuilder content: () -> some View) -> some View {
        content()
            .focusable()
            .focused($focused, equals: card.path)
            .focusEffectDisabled()
            .onTapGesture {
                open(card.path, inNewTab: NSEvent.modifierFlags.contains(.command))
            }
            .onKeyPress(.return) {
                open(card.path, inNewTab: NSEvent.modifierFlags.contains(.command))
                return .handled
            }
            .help(card.path.rawValue)
    }

    // MARK: - Helpers

    private func colour(of folder: NotePath) -> Color? {
        folderColours.colour(for: folder)?.color
    }

    private func cardColour(_ path: NotePath) -> Color {
        folderColours.colour(for: path)?.color ?? AppLabelColor.neutral
    }

    private func label(of card: NoteCard) -> String {
        if let tag = card.tag {
            return "#\(tag)"
        }

        return card.path.parent.isRoot ? "" : card.path.parent.rawValue
    }

    private func open(_ path: NotePath, inNewTab: Bool) {
        Task {
            if inNewTab {
                await navigation.openInNewTab(path)
            } else {
                await navigation.open(path)
            }
        }
    }

    private func move(_ direction: MoveCommandDirection) {
        let paths = order
        guard paths.isEmpty == false else {
            return
        }

        let current = focused.flatMap { paths.firstIndex(of: $0) }
        let step = switch direction {
        case .left, .up:
            -1
        case .right, .down:
            1
        @unknown default:
            0
        }
        let next = current.map { min(max($0 + step, 0), paths.count - 1) } ?? 0
        focused = paths[next]
    }
}
