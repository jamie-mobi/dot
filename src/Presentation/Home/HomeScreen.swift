//
//  HomeScreen.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct HomeScreen: View {
    // MARK: - Environment

    @Environment(\.serviceGraph) private var graph
    @Environment(\.navigationService) private var navigation
    @Environment(\.searchService) private var search
    @Environment(\.folderColourService) private var folderColours
    @Environment(\.indexService) private var index
    @Environment(\.linkService) private var links

    // MARK: - Input

    let packName: String
    let layout: HomeLayout

    // MARK: - State

    @FocusState private var focused: NotePath?

    // MARK: - Derived

    private var home: PackHome {
        graph.home.home
    }

    private var order: [NotePath] {
        home.recent.map(\.path) + home.groups.flatMap { $0.cards.map(\.path) }
    }

    // MARK: - View

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    HomeSearchBar(onSearch: openSearch)

                    if home.recent.isEmpty {
                        ContentUnavailableView(
                            String(localized: "No Notes Yet"),
                            systemImage: "doc.text",
                            description: Text(String(localized: "Press ⌘N to write your first Note."))
                        )
                    } else {
                        CardSectionView(
                            title: String(localized: "Recently edited"),
                            count: home.recent.count,
                            kind: .recent,
                            cards: home.recent.map { item($0, now: context.date) },
                            layout: layout,
                            item: cell
                        )
                        ForEach(home.groups) { group in
                            CardSectionView(
                                title: group.folder.name,
                                count: group.noteCount,
                                kind: .folder,
                                cards: group.cards.map { item($0, now: context.date) },
                                layout: layout,
                                item: cell
                            )
                        }
                    }
                }
                .padding(AppSpacing.large)
            }
        }
        .onMoveCommand(perform: move)
        .task(id: HomeKey(index: index.revision, links: links.mapRevision)) {
            await graph.home.refresh()
        }
    }

    // MARK: - Cell

    @ViewBuilder
    private func cell(_ item: HomeCard) -> some View {
        Group {
            switch layout {
            case .cards:
                NoteCardView(item: item, isFocused: focused == item.id)
            case .list:
                NoteListRow(item: item, isFocused: focused == item.id)
            }
        }
        .focusable()
        .focused($focused, equals: item.id)
        .focusEffectDisabled()
        .onTapGesture {
            open(item.id, inNewTab: NSEvent.modifierFlags.contains(.command))
        }
        .onKeyPress(.return) {
            open(item.id, inNewTab: NSEvent.modifierFlags.contains(.command))
            return .handled
        }
        .help(item.id.rawValue)
    }

    // MARK: - Items

    private func item(_ card: NoteCard, now: Date) -> HomeCard {
        HomeCard(
            card: card,
            colour: folderColours.colour(for: card.path)?.color ?? AppLabelColor.neutral,
            location: location(of: card),
            edited: RelativeAgeUseCase.age(of: card.modified, now: now).longText(for: card.modified)
        )
    }

    private func location(of card: NoteCard) -> String {
        if let tag = card.tag {
            return "#\(tag)"
        }

        return card.path.parent.isRoot ? packName : card.path.parent.rawValue
    }

    // MARK: - Actions

    private func openSearch() {
        Usage.feature(.searchPack)
        search.show()
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
