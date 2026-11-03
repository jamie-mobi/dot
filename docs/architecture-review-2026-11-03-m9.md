# Architecture review — 03/11/2026, after M9 (Redesign)

Survey: `CLAUDE.md`, `ARCHITECTURE.md`, `docs/adr/` (0009 is new), `docs/FIXLOG.md`, the last review (`architecture-review-2026-11-03-m7.md`), the last 30 days of commits and file sizes, with the code M9 added: `FolderColourService`, `VaultHomeService`, the Starred Notes code in `NavigationService`, the per-Vault `UserDefaults` stores and `EditorMetrics`.

Baseline: 422 tests pass (`cd Modules/OpalKit && xcrun swift test`), except the first-index performance budget, which also fails on `main` (about 40 s against 20 s). The Debug build succeeds.

Trigger: end of a milestone.

No Swift file is over 600 lines. The largest are `MarkdownTextViewCoordinator` (441), `MarkdownNoteParser` (408), `NavigationService` (387; 343 at the last review), `VaultService` (380) and `LinkService` (349). The drifted-copies check found nothing.

## Starred Notes live in the window's `NavigationService`  [Strong]

Files: `Modules/OpalKit/Sources/OpalCore/Services/NavigationService.swift` (387 lines, +44 in M9), `RenameService.swift`, `ServiceGraph.swift`, `src/Presentation/Vault/FolderTreePane.swift`, `src/Presentation/Commands/*`.
Signal: end of a milestone; `NavigationService` grew by 44 lines for a job that is not navigation. M9 built the same kind of state twice in two shapes: Folder colours got their own `FolderColourService`, Starred Notes went into `NavigationService`.
Problem: Starred Notes are a per-Vault list saved in Opal's preferences. They have nothing to do with panes, tabs or history. Because `NavigationService.forget` and `move` are synchronous, they save the stars in a detached `Task`, so a test of a rename must sleep 50 ms before it can read the store. `NavigationService` also needs a fifth dependency (`StarredNotesStoring`) only for this.
Proposal: a `StarredNoteService` with the same shape as `FolderColourService`:

```swift
@MainActor @Observable
public final class StarredNoteService {
    public private(set) var notes: [NotePath]
    public init(vault: VaultService, store: any StarredNotesStoring)
    public func isStarred(_ path: NotePath) -> Bool
    public func load() async
    public func toggle(_ path: NotePath) async
    public func move(from old: NotePath, to new: NotePath) async
    public func forget(_ path: NotePath) async
}
```

`ServiceGraph` owns it as `stars`. `RenameService` calls it beside `folderColours`. Views read `graph.stars` through a new `starredNoteService` environment value.
Benefits: locality (one file holds the stars), the two per-Vault preference features look the same, `NavigationService` loses a dependency and about 40 lines, and the rename test no longer sleeps.
Proof of same behavior: the five `StarredNotesTests` move to the new service and keep their expectations. The full suite and the app build pass.
Plan: one commit (new service, callers moved, old code deleted, tests moved).

## The per-Vault `UserDefaults` stores repeat one pattern  [Speculative]

Files: `UserDefaultsRecentNotesStore`, `UserDefaultsStarredNotesStore`, `UserDefaultsFolderColourStore` (about 42 lines each).
Signal: three near-copies with a key prefix plus the Vault path.
Why not: each is small and obvious, and a generic store would hide the value type. The deletion test fails both ways: nothing spreads if one goes.

## `EditorMetrics` now holds Home, Switcher and Palette sizes  [Speculative]

Files: `Modules/OpalKit/Sources/OpalDesign/EditorMetrics.swift` (77 lines, 56 constants).
Signal: the name says Editor, the contents now cover four screens.
Why not: renaming touches many views for no change in behavior. Look again when it passes 100 constants.

## Still open from earlier reviews

- The Editor coordinator's four jobs (441 lines) — Worth exploring, unchanged.
- Launch flags inside `RootScreen.task` — Worth exploring, unchanged.
- `NavigationService` saves the window state at twelve call sites — Speculative, unchanged.

## Considered, not recommended

- **A shared "per-Vault path state" protocol for recents, stars and Folder colours.** Each has different rules (recent order, a list, colours inherited by children). A protocol would be a seam with no second adapter.
- **Splitting `VaultScreen` or `NoteScreen`.** Both stay under 270 lines after M9.

## Top recommendation

Move Starred Notes into `StarredNoteService`. It is Strong, so this unattended run does it.

## Addendum: end of Milestone 10

- The Strong card was done in `ffce84c`: `StarredNoteService` holds the stars, and `NavigationService` is back to 343 lines.
- M10-04 added `BlockIDService` with a plan-then-apply interface. It writes only when the file still matches the plan, the same guard a future "write to another Note" feature should reuse.
- `MarkdownTextViewCoordinator` grew to 453 lines (+12), and `MarkdownTextView` now has 19 parameters (+1, `newBlockInsertion`). The coordinator card stays Worth exploring; a `LinkSuggestionController` would now own the confirm step too.
- M10-03 made `IndexService.read` parse each batch in a task group. The first Index of 10,000 Notes fits its budget again; see `docs/FIXLOG.md`.
- No Swift file is over 600 lines, and no new card is Strong, so nothing more is refactored.
