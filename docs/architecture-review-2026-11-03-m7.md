# Architecture review — 03/11/2026, after M7 (Gaps), before M8

Survey: `CLAUDE.md`, `ARCHITECTURE.md`, `docs/FIXLOG.md`, the last review (`architecture-review-2026-10-29-m6.md`), the last 30 days of commits and file sizes, with the code M8 will change: `MarkdownTextViewCoordinator`, `LinkSuggestionPanel`, `LinkSuggestionUseCase`, `AppCommand`, `EditorStyle` and `EditorSettingsView`.

Baseline: 343 tests in 61 suites pass (`cd Modules/OpalKit && xcrun swift test`), the Debug build succeeds, and the one test in `tests/` passes.

Trigger: end of a milestone, a type over 400 lines, and "before a big feature" (M8). The question for M8: what change to the code would make it easy?

No Swift file is over 600 lines. The largest are `MarkdownTextViewCoordinator` (439, the type about 427), `MarkdownNoteParser` (398), `VaultService` (380), `LinkService` (349) and `NavigationService` (343). The drifted-copies check found nothing. The only `DispatchQueue` is the one ADR 0003 allows.

**Result: the code is in good shape for M8, and no card is Strong.** So nothing is refactored before M8.

## The Editor coordinator holds four jobs in one 427-line class  [Worth exploring]

Files: `src/Presentation/Note/MarkdownTextViewCoordinator.swift` (439 lines; 425 at the last review).
Signal: a type over 400 lines. M8-01 and M8-02 change the `[[` suggestions, which live in this class.
Problem: as in the last review, one class is the text, layout and content delegate and owns the `[[` panel, the fold, the style window, scroll and reveal.
Proposal: the `LinkSuggestionController` from the last review.
Why not now: M8 barely needs it. Finding the query and the suggestions is pure code in `LinkSuggestionUseCase`, which unit tests already cover. The Heading and Block work goes there, and the coordinator only passes a richer query along. The proof the last review asked for still does not exist: the panel is a separate window that a snapshot does not draw.
Proof, when picked: M8-01's `*.panel.png` from `-OpalSnapshot` covers the rows, but not the keys. Up, Down, Return, Tab and Esc still need someone at the keyboard.

## Launch flags are a script inside `RootScreen`'s `.task`  [Worth exploring]

Files: `src/Presentation/Root/RootScreen.swift` (144), `LaunchRequest.swift`, `LaunchArguments.swift` (140).
Signal: test hooks in the app target. `LaunchArguments` and `RootScreen` are among the most-changed files in the last 30 days.
Problem and proposal: unchanged from the last review. `-OpalHideInspector` is still flaky and still not reproduced.
Why not now: M8 adds at most one flag. Moving the code without a reproduction may leave the flake in place.

## Shortcuts are static values in `AppCommand`  [Worth exploring]

Files: `src/Presentation/Commands/AppCommand.swift`, `AppCommandRunner.swift`, `OpalCommands.swift` (⇧⌘P is written there, outside the list).
Signal: before a big feature. M8-03 to M8-05 make shortcuts editable.
Problem: `AppCommand.shortcut` is a fixed `KeyboardShortcut`, the palette reads the same value, and the Command Palette's own command is not in the list.
Proposal: `AppCommand` keeps its defaults. The rules (what may be a shortcut, conflicts, removed or default) go in a pure Domain use case over plain values, and the saved choices go in `OpalSettings`. The Command Palette becomes one more `AppCommand` case.
Why not as a refactor: it has no value apart from M8-03, so it is built as part of that story.

## `NavigationService` saves the window state at twelve call sites  [Speculative]

Files: `Modules/OpalKit/Sources/OpalCore/Services/NavigationService.swift` (343).
Signal: the last review said to look again at a thirteenth call site. There are still twelve, so nothing changes.

## Closed since the last review

- Property types in the form: done in M7-03.

## Considered, not recommended

- **`MarkdownTextView`'s 18 parameters.** M8 adds none, and no change has broken on them.
- **Splitting `NavigationService` or `MarkdownNoteParser`.** Same reasons as the last two reviews.
- **Moving `EditorFontDesign` out of Presentation for M8-06.** The Editor's font settings are Opal-only and already live in `@AppStorage`, so a font family fits beside them.

## Top recommendation

None to do now. Every card is Worth exploring or Speculative, so this unattended run leaves them for the user and goes on to M8.
