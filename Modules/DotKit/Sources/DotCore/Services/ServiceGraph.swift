//
//  ServiceGraph.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation

@MainActor
public final class ServiceGraph {
    // MARK: - Services

    public let pack: PackService
    public let notes: NoteService
    public let links: LinkService
    public let index: IndexService
    public let navigation: NavigationService
    public let switcher: QuickSwitcherService
    public let search: SearchService
    public let mentions: MentionService
    public let dailyNotes: DailyNoteService
    public let templates: TemplateService
    public let renames: RenameService
    public let folderColours: FolderColourService
    public let stars: StarredNoteService
    public let blockIDs: BlockIDService
    public let home: PackHomeService
    public let tagSuggestions: TagSuggestionService
    public let settings: SettingsService

    // MARK: - Init

    public init(
        pack: PackService,
        makeIndex: @escaping @Sendable (URL) throws(IndexError) -> any IndexStoring,
        recents: any RecentNotesStoring,
        starred: any StarredNotesStoring,
        folderColours: any FolderColourStoring,
        windowID: UUID,
        windows: any WindowListStoring,
        settings: SettingsService,
        clock: any Clocking,
        tagSuggester: any TagSuggesting,
        saveDelay: Duration = .milliseconds(800)
    ) {
        let index = IndexService(pack: pack, makeIndex: makeIndex)
        let links = LinkService(pack: pack, index: index)
        let notes = NoteService(pack: pack, links: links, index: index, clock: clock, saveDelay: saveDelay)
        let navigation = NavigationService(pack: pack, notes: notes, links: links, recents: recents, windowID: windowID, windows: windows)
        self.pack = pack
        self.index = index
        self.links = links
        self.notes = notes
        self.navigation = navigation
        switcher = QuickSwitcherService(pack: pack, links: links, navigation: navigation)
        search = SearchService(index: index, navigation: navigation)
        mentions = MentionService(pack: pack, index: index, links: links, notes: notes)
        dailyNotes = DailyNoteService(pack: pack, links: links, navigation: navigation, clock: clock)
        templates = TemplateService(pack: pack, notes: notes, clock: clock)
        let colours = FolderColourService(pack: pack, store: folderColours)
        self.folderColours = colours
        let stars = StarredNoteService(pack: pack, store: starred)
        self.stars = stars
        blockIDs = BlockIDService(pack: pack, notes: notes)
        home = PackHomeService(index: index, links: links)
        tagSuggestions = TagSuggestionService(suggester: tagSuggester, links: links, settings: settings)
        renames = RenameService(pack: pack, links: links, notes: notes, navigation: navigation, folderColours: colours, stars: stars)
        self.settings = settings
        settings.attach(pack)
        pack.onExternalChange = { [index, links, notes] paths in
            await index.update(paths)
            await links.refresh(paths)
            await notes.reloadIfUnchanged(paths)
        }
    }

    // MARK: - Intent

    public func syncFollowers() async {
        await index.sync()
        await links.sync()
    }
}
