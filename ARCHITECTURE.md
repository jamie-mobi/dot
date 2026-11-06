# Dot architecture

The rules are in [docs/architecture.md](docs/architecture.md). This file names
Dot's pieces and its deliberate constraints.

**Status: Milestones 1 to 8 built** (see
[docs/user-stories.md](docs/user-stories.md)). Lines marked _built_ exist on
`HEAD`; everything else is still the target shape. When code lands, replace a
planned line with what was built, and add each new protocol, store and
constraint here.

## Built in Milestone 1

| Layer | Built |
| --- | --- |
| Domain | `Pack`, `NotePath`, `PackEntry`, `PackItemKind`, `PackTreeNode`, `Note`, `ObsidianAppSettings`, `NewFileLocation`, `PackError`. Use cases: `PackTreeUseCase` (tree, Finder order, hidden items), `NewItemPlanUseCase` (where and what a new Note or Folder is called), `NoteSaveDecisionUseCase` (write, skip, adopt, recreate or conflict), `DetailContentUseCase`, `WindowTitleUseCase` |
| Data | `FileSystemPackStore` (actor), `ObsidianAppSettingsParser` + `ObsidianAppSettingsDTO`, `SecurityScopedPackAccess`, `UserDefaultsPackLocationStore` |
| Services | `PackService` (open, create, reopen, tree, new Note and Folder, reload), `NoteService` (open Note, edits, debounced autosave, conflict), `SingleFlightRefreshing` |
| Design | `AppSpacing`, `EditorMetrics` |
| Presentation | `RootScreen`, `WelcomeView`, `PackScreen`, `FolderTreeView` + `FolderTreeRow`, `NoteScreen`, `MarkdownTextView` (TextKit 2, [ADR 0002](docs/adr/0002-textkit-2-editor.md)), `ConflictBanner`, `AttachmentView`, `SaveStatusView`, `DotCommands`, `PackActions` |
| App | `DotApp` (a `WindowGroup` of window ids, with SwiftUI restoration off; ADR 0008), `DotAppDelegate` (saves on quit and on resign active), `AppDependencies`, `AppGraph`, `LaunchArguments` (and `LaunchRequest` in Presentation) |
| Infrastructure | `MockPackFileStore`, `MockPackAccess`, `MockPackLocationStore`, `PreviewGraph` |

## Built in Milestone 2

| Layer | Built |
| --- | --- |
| Domain | `Link`, `LinkSubpath`, `LinkStyle`, `Heading`, `Block`, `ParsedNote`, `TextSpan`, `Backlink`, `BacklinkGroup`, `OutgoingLink`, `TextStyleRun` + `TextStyleKind` (was `LinkHighlight`), `LinkDestination`, `LinkQuery`, `LinkSuggestion`, `LinkResolver` (path, relative path, name with shortest path, Alias), `LinkMap` (in-memory Backlinks and Unresolved targets), `NavigationHistory`, `RevealRequest`, `SwitcherCandidate`, `SwitcherMatch`. Use cases: `LinkFollowUseCase`, `BacklinkGroupUseCase`, `LinkSuggestionUseCase`, `QuickSwitcherMatchUseCase`, `TextLineUseCase` |
| Data | `MarkdownNoteParser` (pure: Links, Embeds, Headings, Blocks, `aliases`; skips code and frontmatter), `FSEventsPackWatcher` ([ADR 0003](docs/adr/0003-fsevents-dispatch-queue-exception.md)), `UserDefaultsRecentNotesStore` |
| Services | `LinkService` (the Link map, rebuilt off the main actor; `openNote`, the open Note's parsed Links, Headings and Link colours, which `NoteService` keeps current), `NavigationService` (open, follow, back and forward, reveal a line, recent Notes, inspector and Quick Switcher visibility), `QuickSwitcherService` (query, results, create, `[[` suggestions; results and suggestions are computed off the main actor from cached candidates). `PackService` gains `entries`, `createNote(at:)`, the watcher and `onExternalChange`; `NoteService` gains `reloadIfUnchanged` and tells `LinkService` after each save |
| Design | `EditorMetrics` inspector, switcher and suggestion sizes |
| Presentation | `InspectorView` + `InspectorPane`, `BacklinksView`, `OutgoingLinksView`, `OutlineView`, `QuickSwitcherView` + `QuickSwitcherRow`, `LinkSuggestionPanel` + `LinkSuggestionList` + `LinkSuggestionRow`; the Editor colours Links, follows them on ⌘-click and reveals a line; Go menu (⌘O, ⌘[, ⌘]) and Toggle Inspector (⌥⌘0) |

## Built in Milestone 3

| Layer | Built |
| --- | --- |
| Domain | `FileStamp`, `IndexedNote`, `IndexSyncPlan` + `IndexSyncPlanUseCase`, `IndexError`, `TagNode` + `TagTreeUseCase`, `SearchQuery` + `SearchQueryUseCase`, `SearchHit`, `SearchResult`, `SearchLine`, `SearchSnippetUseCase`, `UnlinkedMention` + `UnlinkedMentionUseCase`, `SidebarPane`. `ParsedNote` gains `tags` and `skippedSpans` and is `Codable` |
| Data | `GRDBIndexStore` (GRDB 7, SQLite, FTS5; [ADR 0004](docs/adr/0004-index-in-sqlite-with-grdb.md)), `FTSQueryBuilder`, `IndexLocation`. `FileSystemPackStore` gains `noteStamps()` and `stamp(of:)`, walking with `enumerator(at:includingPropertiesForKeys:)` |
| Services | `IndexService` (sync by file stamps, in batches, with progress; updates on saves and outside changes), `SearchService` (query, debounce, results), `MentionService` (unlinked mentions, link after confirmation). `LinkService` loads parsed Notes from a ready Index; the Link map also builds the Tag tree |
| Presentation | Sidebar panes (Files, Search, Tags), `SearchView`, `TagsView`, `IndexStatusView`, `UnlinkedMentionsSection`; ⇧⌘F |

## Built in Milestone 4

| Layer | Built |
| --- | --- |
| Domain | `TextStyleRun` + `TextStyleKind` (Links, marks, Headings, emphasis, code, quotes, callouts, lists, checkboxes, rules, Tags, frontmatter, done tasks). `CheckboxToggleUseCase` + `CheckboxToggle` (the one character a click changes). `TextSpan.shifted(by:)`, `TextLineUseCase.line(atOffset:in:)`. Reading view: `ReadingBlock` + `ReadingBlockKind`, `ReadingInline` + `ReadingInlineStyle`, `CodeToken` + `CodeTokenKind`, `ReadingBlockID`. Embeds: `EmbedContent`, `EmbedMedia`, `EmbedUseCase` (media kind, `|width`, the lines of a Heading's section or a Block's paragraph). Attachments: `AttachmentUseCase` (folder from `attachmentFolderPath`, pasted-image name, a free name, Embed text in the Pack's `LinkFormat`). `ObsidianAppSettings` gains `newLinkFormat`. Properties: `Frontmatter`, `Property`, `PropertyValue`, `PropertyType`, `PropertyTypeUseCase` (value, name, `types.json`), `PropertyEditUseCase` (set, add, remove: only that Property's lines change). `TagTreeUseCase.searchQuery(forTag:)` |
| Data | `MarkdownStyleParser` (pure: text and `ParsedNote` in, style runs out; shares line, fence and code helpers with `MarkdownNoteParser`), `MarkdownReadingParser` + `ReadingInlineBuilder` (reading blocks from the same parse, [ADR 0005](docs/adr/0005-reading-view-in-swiftui.md)), `CodeTokenizer` (keywords, strings, numbers, comments for Swift, Python, JavaScript, JSON, YAML, shell), `FrontmatterParser` (Properties with their source lines; YAML it cannot read is kept as it is), `ObsidianTypesParser` + `ObsidianTypesDTO` (`.obsidian/types.json`, read only). `PackFileStoring.createFile(at:data:)` (never replaces a file). `Clocking` |
| Services | `LinkService.openNote`: Link colours plus Markdown style runs (sorted by location), the Link-only runs and the frontmatter, always computed off the main actor (200 ms debounce over 64 KB). Not stored in the Index. `LinkService.readingBlocks(of:text:)` builds reading blocks off the main actor; `LinkService.embed(_:from:chain:)` resolves and reads an Embed ([ADR 0006](docs/adr/0006-embeds-only-in-reading-view.md)); `mapRevision`. `NavigationService.isReadingView` and `editorTopOffset`. `PackService.propertyTypes`; `NoteService.frontmatter`, `type(of:)`, `setProperty`, `removeProperty`, `addProperty`, `toggleCheckbox(onLine:)`, `attach(_:named:)`; `PackService.createAttachment` |
| Design | `EditorMetrics` Heading scales, code scale, block indent and bar width |
| Presentation | `MarkdownStyler` (style kind to text storage attributes, only in a window around what is on screen; mark fading), `MarkdownBlock` + `MarkdownBlockFragment` (TextKit 2 layout fragments draw quote bars, callout and code block backgrounds), `EditorPreferences`; View › Live Markdown; clicking a checkbox toggles it as one undo step. `ReadingView` + `ReadingBlockView` + `ReadingText` + `CalloutStyle` + `ReadingKey` + `EmbedView` + `EmbedKey` + `PDFEmbedView` (Presentation/Reading); View › Reading View (⌘E) and a toolbar button. `PropertiesView` + `PropertyRow` + `PropertyType+Display` above the Editor and Reading view; `NoteTagsView`, the inspector's Tags tab |
| App | Debug-only `-DotSnapshot <png>` draws the window to a PNG and quits; `-DotReadingView` opens in Reading view. `SystemClock` (the only reader of the date and time zone) |

## Built in Milestone 5

| Layer | Built |
| --- | --- |
| Domain | `TabList` + `NoteTab` (tabs, each with its own history and scroll position). `EditorPanes` (one `TabList` per pane, at most two, and the focused pane). Settings: `DotSettings` (Codable, missing keys take defaults), `PackSettings` (what the Pack's Obsidian files set), `SettingsUseCase` (the Pack's value wins per key), `LinkUpdate`. `CommandMatchUseCase` (fuzzy command names, recent first). `DailyNoteSettings`, `MomentFormatUseCase` (Moment date tokens), `DailyNotePlanUseCase` (path and Template path), `TemplateFillUseCase` (`{{date}}`, `{{time}}`, `{{title}}`, with formats), `TemplateSettings`, `TextInsertion`. Rename: `RenameUseCase` (new name checks), `RenameProblem`, `RenamePlan` (every moved file and the Notes that link to them), `LinkRewriteUseCase` (rewrites Links to moved files, keeping style, subpath, alias and relative form). `NotePath.appendingNoteExtension`, `replacingPrefix(_:with:)`, `NavigationHistory.move`; `NavigationService.move(from:to:)`, `forget(_:)`, `isCommandPaletteShown`; tabs (`tabs`, `openInNewTab`, `selectTab`, `closeTab`, `selectNeighbourTab`, `restoreTabs`), saved per Pack by `RecentNotesStoring.openTabs`. `QuickSwitcherService.confirm(inNewTab:)` |
| Data | `ObsidianVaultSettingsParser` (which keys `app.json` and `daily-notes.json` set, including `alwaysUpdateLinks`); `SettingsStoring` + `UserDefaultsSettingsStore`. `ObsidianDailyNotesParser` + DTO (`.obsidian/daily-notes.json`), `ObsidianTemplatesParser` + DTO (`.obsidian/templates.json`); both read only. `PackFileStoring.moveItem(from:to:)` (case-only renames go through a temporary name), `trashItem(at:)` (macOS Trash; tests pass `trashFolderURL`) |
| Services | `WindowRegistry` (a graph per window id, the saved window list through `WindowListStoring`, where to open a Pack through `OpenPackUseCase`, closing a window) and one `SettingsService` shared by every Pack. `ServiceGraph` builds every service and wires the outside-change followers (Index, then Link map, then open Notes) once; `AppGraph` and the tests' `ServiceHarness` both use it, and `PackSync` calls `syncFollowers()`. `SettingsService` (Dot's settings through `SettingsStoring`; `PackService.appSettings`, `dailyNoteSettings` and `linkUpdate` are the effective values). `NoteDocument` (one open Note: draft, load, save, conflict) and `NoteService` as the registry of documents the panes show, whose API means the focused pane's Note (ADR 0007); `LinkService.analyses` (one per open document, `openNote` is the focused one); `NavigationService.panes`, `splitRight`, `focusPane`, `showPanes`. `DailyNoteService` (open or create today's Daily Note through `Clocking`); `RenameService` (move to the Trash, closing the open Note; plan a rename or move, then move the file, rewrite Links in each linking Note atomically, and update the open Note, history and Index); `TemplateService` (Templates in the Templates Folder, fill for the open Note, an insertion request the Editor applies at the cursor); `PackService.dailyNoteSettings`, `templateSettings`, `createNote(at:text:)`, `duplicate(_:)` |
| Presentation | `WindowScreen` injects its window's graph (`View.serviceGraph(_:)`), publishes it as a focused scene value for `DotCommands`, and reopens saved windows; File › New Window (⇧⌘N; New Folder… moved to ⌥⌘N); `-DotNewWindow`. Settings window (`SettingsScreen`: Editor, Files and Links, Daily Notes, Appearance) with `SetByPackNote`; `EditorStyle` (font design, size, line spacing, line width, spell check) passed into `MarkdownTextView` and `MarkdownStyler`; `-DotSettings editor\|files\|daily\|appearance` opens it and the snapshot draws that window. View › Split Right (⌘\) shows a second Editor pane with its own `TabBarView`; `NoteScreen(pane:)`; clicking into a pane focuses it; `-DotSplit <path>`. `TabBarView` above the Editor; ⌘T, ⌘W, ⌃⇥ and ⌃⇧⇥; Open in New Tab in the Folder tree; ⌘Return in the Quick Switcher. `AppCommand` + `AppCommandRunner`: one list of commands for the menus and the Command Palette (⇧⌘P, `CommandPaletteView`, `CommandPaletteRow`). Go › Today's Daily Note (⌥⌘D) and a toolbar button; Edit › Insert Template… (⌥⌘T) and `TemplatePickerView`; Folder tree: Rename… and Return rename in place (`FolderTreePane`, `FolderTreeActions`), with an "Update Links in N Notes?" dialog; drag a row onto a Folder or Move to… (`MoveToFolderView`) to move; Duplicate in the context menu and File › Duplicate Note; Move to Trash (⌘⌫) after confirmation; `-DotDailyNote`, `-DotTemplates`, `-DotRename <path>`, `-DotMove <path>`, `-DotDelete <path>`, `-DotCommandPalette`, `-DotTabs a.md,b.md`. Flags without a value go last on the command line. `-DotSnapshot` also writes an attached sheet as `*.sheet.png` |

## Built in Milestone 6

| Layer | Built |
| --- | --- |
| Domain | `WindowState` (both panes' tabs, focused pane, split share, frame), `WindowFrame` (`clamped` moves a frame onto a current screen). `EditorPanes.splitShare` and `clampedShare`. `RecentPacksUseCase`, `RecentPack`, `RecentPackRecord`. `FrontmatterFold`, `FrontmatterFoldRule`, `FrontmatterFoldUseCase` (display only; the text is never touched). `PropertyIndexUseCase` |
| Data | `GRDBIndexStore` schema 6: one `note_properties` row per Property item, and `propertyTypes(declared:)`. `UserDefaultsWindowListStore` keeps each `WindowState`; `UserDefaultsPackLocationStore` keeps the recent Packs |
| Services | `RecentPacksService` (app-wide: at most ten, newest first, a missing folder marked). `SearchService` reads `[name:value]`, `[name]` and a negated filter. `NavigationService` saves the window state and tracks `unfoldedFrontmatter` |
| Design | One token set: `AppColor`, `AppKitColor`, `AppOpacity`, `AppRadius`, `AppMotion`, `AppSpacing`, `EditorMetrics`, documented in [docs/design/DESIGN-SYSTEM.md](docs/design/DESIGN-SYSTEM.md). `PresentationTokenCheckTests` fails on a literal value in `src/Presentation` |
| Presentation | `Icon/AppIcon.icon`. `SplitPanesView` draws its own divider (`HSplitView` is not used); `WindowFrameModifier`, `WindowReader`. `RecentPackRow` and File › Open Recent. Reading view reads the `editorStyle` environment value. `MarkdownBlockFragment` draws checkboxes and the folded frontmatter line |
| App | `-DotSplitShare <0..1>`, `-DotHideInspector`, `-DotRestoreState`, `-DotEditAsYAML`, `-DotRecentPacks <path,path>` |

## Built in Milestone 7

| Layer | Built |
| --- | --- |
| Domain | `FrontmatterFold.selectionAfterFolding`. `FolderPathUseCase` (a short path for a recent Pack) and `UserHome` (the real home folder from the user database, because `NSHomeDirectory()` is the app's container in the sandbox) |
| Services | `NoteDocument.refreshPropertyTypes()` (the Index's Pack-wide types once it is ready). `NavigationService.foldFrontmatter(of:)` |
| Design | `EditorMetrics`: sidebar 220 and Inspector 260 ideal widths, so a split fits the default window |
| Presentation | Hide YAML in `PropertiesView`, which also refreshes types on `index.revision`. `RecentPack.shortParentPath` in the Welcome window and File › Open Recent |

## Built in Milestone 8

| Layer | Built |
| --- | --- |
| Domain | `LinkQueryScope` (Notes, Headings or Blocks of a target) on `LinkQuery`, `LinkTail` (what follows the cursor up to `]]`), `LinkSuggestion.heading` and `.block`; `LinkSuggestionUseCase.linkText(forHeading:)`, which `LinkFollowUseCase` also uses to compare Headings. `Block.text`. Shortcuts: `CommandShortcut`, `ShortcutModifier`, `ShortcutChoice` (custom or removed), `ShortcutProblem`, `ShortcutUseCase`. `EditorFontFamily` + `EditorFontFamilyUseCase`. `DotSettings.shortcuts` and `reopensPacksAtLaunch` |
| Data | `GRDBIndexStore` schema 7, because the stored parse now holds `Block.text` |
| Services | `QuickSwitcherService.linkSuggestions(for:from:)` takes a `LinkQuery`. `WindowRegistry(restoresWindows:)` |
| Design | `EditorMetrics.shortcutsListHeight` |
| Presentation | `AppCommand` keeps only default shortcuts and now includes the Command Palette; `AppCommandRunner` and the palette read the effective shortcut. `ShortcutsSettingsView` + `ShortcutRow` + `ShortcutConflict` + `ShortcutRecordingModifier`; `GeneralSettingsView`. `InstalledFonts`, `EditorFontChoice`, `EditorStyle.family` |
| App | `-DotSnapshot` also writes the first child window as `*.panel.png`; `-DotShortcutState recording\|conflict\|reserved` |

## Built in Milestone 9

| Layer | Built |
| --- | --- |
| Domain | `RelativeAgeUseCase`, `FolderColour` + `FolderColourUseCase` (a Folder's colour is inherited by everything inside it), `NotePreviewUseCase`, `PackHomeUseCase` (recent Notes and Folder groups for the Pack home), `NoteStatsUseCase`, `BacklinkGroupUseCase.markedContexts(in:)`, `SearchFilterUseCase` and `SearchLine.kind`, `FuzzyHighlightUseCase` |
| Data | `StarredNotesStoring` + `UserDefaultsStarredNotesStore` and `FolderColourStoring` + `UserDefaultsFolderColourStore`, saved per Pack in Dot's preferences, never in the Pack. `IndexStoring.texts(of:)`. `PackFileStoring.created(of:)` |
| Services | `StarredNoteService` (`ServiceGraph.stars`) and `FolderColourService` (`ServiceGraph.folderColours`): one per window, loaded per Pack; `RenameService` moves or drops their entries on a rename or a move to the Trash. `PackHomeService` (`ServiceGraph.home`) |
| Design | `AppAccent` (Dot or System, ADR 0009), `AppBrandColor`, `AppDynamicColor`, `AppSurface`, `AppLabelColor`; more `AppSpacing`, `AppRadius` and `AppOpacity` steps; `EditorMetrics` card, home, switcher and palette sizes |
| Presentation | Pack home (`PackHomeView`, `NoteCardView`), Starred and Recent Notes in the sidebar, `NoteStatusBar`, `PropertyPills`, `BacklinkCard`, `SwitcherPreview`, `KeyHintBar`, the Accent setting |

## Built after Milestone 9: Tag suggestions

| Layer | Built |
| --- | --- |
| Domain | `TagSuggestionRequest`, `TagSuggestionAvailability`, `TagSuggestionError`, `TagSuggestionUseCase` (the request, cleaning the model's output, which suggestions show, adding a Tag to a `tags` value). `DotSettings.suggestsTags` (off by default) |
| Data | `TagSuggesting` + `FoundationModelsTagSuggester` (on-device `SystemLanguageModel`, `contentTagging`), `GeneratedTagsDTO` (`@Generable`), `TagSuggestionPrompt` ([ADR 0011](docs/adr/0011-on-device-tag-suggestions.md)) |
| Services | `TagSuggestionService` (`ServiceGraph.tagSuggestions`): suggestions per Note, held in memory, `loadState(for:)`, `suggest`, `resuggest`, `accept`. `NoteDocument.addTag(_:)` |
| Services (reveal) | `NavigationService.revealInFolderTree()` and `folderTreeReveal`: Go › Reveal in Folder Tree (⌥⇧J) shows the sidebar and the Note, expands to the open Note, selects it, scrolls to it and focuses the tree |
| Presentation | `TagSuggestionsBar` + `TagSuggestionsView` under the Properties (a sparkles line; click a Tag to add it), Settings › General › Suggest Tags |

## Built after Tag suggestions: the dot_design port

The interface now follows the `dot_design` project ([ADR 0012](docs/adr/0012-adopt-the-dot-design-project.md)).

| Layer | Built |
| --- | --- |
| Domain | `PackDestination` (Home, Search or Note) replaces `SidebarPane`. `NotePreviewLine` (a preview line and whether it was a list item) and `NotePreviewUseCase.lines(of:title:maxLines:)`. `CommandShortcut.keyCaps` |
| Services | `NavigationService.destination`, `showHome()`, `showSearch()`, `showNote()`, `canGoBack`, `canGoForward`: Back from Search returns to where the user was, Back from the first Note goes Home. `SearchService.show` shows the Search screen. `NoteCard.lines` |
| Design | The design project's tokens as they are: `AppFont`, `AppSpacing.snug`/`roomy`, `editorMargin 56`, `AppRadius.tiny 6`/`row 8`/`panel 18`, `AppColor` text, line, fill, field, popover, scrim and shadow roles, `EditorMetrics` window, Home, Search, panel, Welcome and Settings sizes |
| Presentation | `NavigationSplitView` with the native `.inspector`; `PackToolbar` (Back, Forward, Cards/List or Editing/Reading, More, Inspector); `HomeScreen` + `CardSectionView`, `NoteCardView`, `NoteListRow`, `HomeSearchBar`; `SearchScreen` + `SearchFieldView`, `SearchFilterBar`, `SearchResultGroupView`; `PackOverlayView` + `CommandPanelView` for the Quick Switcher, Command Palette and Template picker; `NoteHeaderView` (title, Properties, Tag suggestions), `ReadingPropertiesView`; Inspector tabs as text with `InspectorSectionHeader`, `UnlinkedMentionCard`, the Note's stats under the Outline; `WelcomeScreen` + `RecentPacksView`; `KeyCapsView`, `KeyHintsView`, `LabelDot`, `TagChip`, `FlowLayout`; Go › Home (⇧⌘H) |

Built protocols: `Clocking`, `PackFileStoring`, `PackAccessGranting`, `PackLocationStoring`, `PackWatching`, `RecentNotesStoring`, `StarredNotesStoring`, `FolderColourStoring`, `IndexStoring`, `SettingsStoring`, `WindowListStoring`, `TagSuggesting`.
Tests: `Modules/DotKit/Tests/DotCoreTests` (`xcrun swift test`, or the `Dot`
scheme's test action).

Launch arguments for acceptance runs, read only in `AppDependencies`:
`-DotPackPath <folder>` opens that folder without remembering it, and
`-DotDefaultsSuite <name>` keeps Dot's preferences in that suite instead of
the app's own domain, `-DotOpenNote <path>` opens a Note, `-DotAppearance
light|dark` forces the look, `-DotQuickOpen <query>` opens the Quick Switcher,
`-DotTypeText <text>` (Debug builds only) types into the Editor,
`-DotIndexFolder <folder>` keeps the Index there, `-DotSearch <query>` runs a
Search on the Search screen.
Debug-only `-DotSnapshot <png>` draws the window to a PNG and quits, and
`-DotReadingView` opens the Note in Reading view. The milestone tables above
list the flags added since. `LaunchArguments` turns the arguments that act on the window into one
`LaunchRequest` value, which `RootScreen` and `NoteScreen` read from the
environment; a new argument touches `LaunchArguments`, `LaunchRequest` and the
view that acts on it.

## Layers

| Layer | Where | What lives there |
| --- | --- | --- |
| Domain | `Modules/DotKit/Sources/DotCore/Domain/` | Value types: `Pack`, `Note`, `NotePath`, `Link`, `LinkTarget`, `Heading`, `Block`, `Tag`, `Property`, `Attachment`. Pure use cases: Link resolution (name, Alias, path, case), Backlinks, unlinked mentions, rename plan (which Links change), Daily Note name and place, search ranking, Quick Switcher match |
| Data | `Modules/DotKit/Sources/DotCore/Data/` | The Pack file store, the file watcher, pure parsers (Markdown, frontmatter, Links, Tags), the Obsidian settings reader, the Index store |
| Services | `Modules/DotKit/Sources/DotCore/Services/` | `PackService` (open Pack, file tree, changes), `NoteService` (the open Note, edits, save), `LinkService` (Backlinks, unlinked mentions, rename), `SearchService`, `QuickSwitcherService`, `DailyNoteService`, `SettingsService` |
| Design | `Modules/DotKit/Sources/DotDesign/` | Design tokens. A leaf module: depends on nothing in the package |
| Presentation | `src/Presentation/` | The window (sidebar, Editor, inspector), the Quick Switcher, the Command Palette, Settings, the `@Entry` keys |
| App | `src/App/` | The composition root: `AppGraph` holds the app-wide `WindowRegistry` (one `ServiceGraph` per window, ADR 0008), the shared `SettingsService`, an empty placeholder graph for environment defaults, and the launch values and defaults. The only place that reads the home folder, saved Pack folder access and other ambient globals |
| Infrastructure | `src/Infrastructure/` | `#if DEBUG` mocks and `PreviewGraph` |

## Protocols

`NoteParsing` and `ObsidianSettingsReading` are still only planned: today the
parsers are called directly. The others are built.

| Protocol | Real implementation | Notes |
| --- | --- | --- |
| `PackFileStoring` | `FileSystemPackStore` (actor) | Lists, reads and writes files inside the Pack root only. Atomic writes. Never follows a link out of the Pack |
| `PackWatching` | `FSEventsPackWatcher` | Reports file changes made outside Dot (Obsidian, git, sync tools) as an `AsyncStream` |
| `NoteParsing` | `MarkdownNoteParser` | Pure: Note text in, Headings, Links, Embeds, Tags, Properties and Blocks out |
| `ObsidianSettingsReading` | `ObsidianSettingsFile` | Reads `.obsidian/app.json`, `daily-notes.json` and `templates.json` when present. Read only |
| `IndexStoring` | `GRDBIndexStore` | The derived Index. Rebuilt from the Pack when missing, damaged or a different schema version |
| `Clocking` | `SystemClock` | Today's date for Daily Notes |

## Deliberate constraints

- **The Pack is the source of truth.** Notes are plain `.md` files. Dot adds no
  hidden file to a Note and no sidecar beside it. Everything Dot knows about a
  Note comes from its file.
- **The Index is derived.** It lives outside the Pack
  (`Application Support/Dot/Indexes/<pack-id>/`). Deleting it loses
  nothing; Dot rebuilds it on the next open.
- **Dot never writes inside `.obsidian/`.** It reads Obsidian's settings so a
  Pack behaves the same in both apps. Dot's own settings live outside the Pack.
- **Dot changes only what it was asked to change.** A save writes the user's text
  as it is. Dot never reformats frontmatter, line endings or whitespace in a part
  of the file the user did not edit.
- **A rename that updates Links asks first.** It shows how many Notes will change,
  then writes each one atomically.
- **Changes from outside win when the Note has no unsaved edits.** When a Note has
  unsaved edits and its file changes on disk, Dot keeps both and asks the user.
- **Obsidian syntax is kept**: wikilinks with alias, Heading and Block targets,
  Embeds, nested Tags, YAML Properties, `aliases`. Dot may render more, but it
  never writes syntax that Obsidian cannot read.
- **No network except usage analytics.** v1 needs no server and no account. Release builds send anonymous feature-usage events to Firebase Analytics ([ADR 0010](docs/adr/0010-firebase-analytics-for-feature-usage.md)); never Note contents, names or paths.
- **Tag suggestions run on this Mac only** ([ADR 0011](docs/adr/0011-on-device-tag-suggestions.md)). Apple's on-device model; no Note text leaves the Mac. Off by default, and nothing is written until the user clicks a suggestion.
- **Sandboxed, with a security-scoped bookmark per Pack** ([ADR 0001](docs/adr/0001-sandboxed-app-with-security-scoped-pack-bookmarks.md)).
- **Symbolic links are skipped.** The Folder tree leaves them out and the store
  refuses to read or write through one, so nothing outside the Pack is touched.
- **A Note must be UTF-8.** Dot refuses to open any other encoding rather than
  risk rewriting it. A byte order mark is kept.
- **Saves never overwrite a change Dot did not see.** Before writing, the store
  re-reads the file; if it differs from what Dot last loaded or saved,
  `NoteSaveDecisionUseCase` reports a conflict and nothing is written.
- **Atomic writes replace the file.** Extended attributes on a Note are not
  carried over in M1.
- **Editor substitutions are off.** Smart quotes, smart dashes, text
  replacement and automatic spelling correction would change text the user did
  not type differently. Settings has no switch for them.
- **One Pack per window, one `ServiceGraph` per window** ([ADR 0008](docs/adr/0008-one-service-graph-per-window.md)).
  `WindowGroup` of window ids, with SwiftUI restoration off.
- **The Pack is watched with FSEvents.** `FSEventsPackWatcher` owns the one
  `DispatchQueue` in Dot ([ADR 0003](docs/adr/0003-fsevents-dispatch-queue-exception.md)).
  Hidden paths are dropped; an open Note reloads only when it has no unsaved
  edits and the disk differs from what Dot last wrote.
- **The Index lives outside the Pack**, one SQLite file per Pack under
  Application Support (`-DotIndexFolder` in tests and acceptance runs). It is
  versioned with `PRAGMA user_version`; any mismatch or damage deletes and
  rebuilds it. GRDB is imported only in `GRDBIndexStore`.
- **The Link map is held in memory** and built from the Index when it is
  ready, from the files otherwise.
- **Performance budget (10,000 Notes, Release):** first index under 20 s,
  reopen under 1 s, Search under 100 ms. `DOT_PERF=1 xcrun swift test -c
  release -Xswiftc -enable-testing --filter LargePackPerformanceTests`.
- **Presentation never parses a Note.** The Editor and the inspector read
  `LinkService.openNote`. Every Note is parsed off the main actor: a Note over
  64 KB 200 ms after typing stops, a smaller one at once (reviews 27/10/2026 and
  28/10/2026).
- **Recent Notes live in Dot's preferences**, keyed by the Pack folder, never
  in the Pack.
- **`[[` suggestions use Dot's own panel**, not `NSTextView` completion, which
  inserts the only match at once while the user is still typing.
- **`UserDefaultsPackLocationStore` is `@unchecked Sendable`.** `UserDefaults`
  is documented as thread-safe but not marked `Sendable`.
- **Panels and Finder actions are called from Presentation.** `PackPanels`
  (`NSOpenPanel`, `NSSavePanel`) and `WorkspaceActions` (`NSWorkspace`) are
  `@MainActor` AppKit calls that Data, which is never `@MainActor`, cannot own.
- **Every App file imports the modules whose types it names.** A view that
  declares an `@Environment` property of an `DotCore` type imports `DotCore`
  itself; Swift 6 member import visibility warns otherwise (review 29/10/2026,
  after M6). The App target builds with zero warnings.

## Open questions

- **Plugins.** Not in v1. Obsidian's JavaScript plugins will not run in Dot.
