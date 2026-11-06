# Dot design system

Dot keeps Apple's look. Tokens live in `Modules/DotKit/Sources/DotDesign` and cover only what the system does not: spacing, radii, opacities, a few custom fills, Editor and window metrics, and motion. A view in `App/Dot/Presentation` never writes a literal colour, spacing, radius, size or animation. `PresentationTokenCheckTests` (Swift Testing, runs with the suite) fails if one appears; `LiteralScannerTests` shows what it flags and what it allows.

Start from `docs/design-brief.md` and the `mac-design` rules. This page says which token to use when.

## Accent

- The accent is Dot-rose by default, with the system accent as a setting (ADR 0009). Use `AppColor.accent` (SwiftUI) or `AppKitColor.accent` (AppKit). They follow Settings › Appearance › Accent through `AppAccent.current`; `AppBrandColor` holds the rose values. Wrap a new window or scene in `followsAccent()`.
- Folder and Tag colours (`AppLabelColor`) are information. Use them only for a card's top edge, a dot and a Folder icon.
- Text or a symbol on an accent fill uses `AppColor.onAccent`, never a fixed white.
- Selected rows in the Quick Switcher, Command Palette and Template picker: `AppColor.accentSoft` behind the row with `AppRadius.inner`, text unchanged. The selected Search line uses `accentSoft` too.
- Never redefine a semantic colour (`.separator`, `.secondary`, label colours). Use them as they are, or through an `AppKitColor` role.

## Colour roles (`AppColor`, `AppKitColor`)

| Need | Token |
| --- | --- |
| Editor and Reading view background | `AppColor.editorBackground`, `AppKitColor.editorBackground` |
| Text, secondary text, quiet text (captions, marks) | `AppColor.text`, `.secondaryText`, `.quietText` (and `AppKitColor`) |
| Card, Search result, Backlink card | `AppColor.surface` |
| Search field, Home search bar | `AppColor.field` |
| Properties block, key caps | `AppColor.fill`; neutral chips `AppColor.strongFill` |
| Selected row (Outline, Recent Packs) | `AppColor.selection` |
| Hairline around a card or chip; stronger line | `AppColor.line`, `AppColor.strongLine` |
| Behind a panel; card and panel shadows | `AppColor.scrim`, `AppColor.cardShadow`, `AppColor.popoverShadow` |
| Welcome icon | `AppColor.iconTop`, `.iconBottom`, `.iconSymbol` |
| Selected row, selected chip | `AppColor.accentSoft` |
| Card preview fade | `AppColor.fadeMask` |
| Inline code and code block fill | `AppColor.codeFill`, `AppKitColor.codeFill` |
| Quote bar | `AppKitColor.divider` |
| Callout fill | `AppColor.calloutFill`, `AppKitColor.calloutFill` |
| `#tag` chip | `AppColor.tagFill`, `AppKitColor.tagFill` |
| Link to a Note that does not exist | `AppColor.unresolvedLink`, `AppKitColor.unresolvedLink` |
| `==highlight==` | `AppColor.highlight`, `AppKitColor.highlight` |
| Matching words in Search results | `AppColor.searchMatch` |
| Error such as "Not Saved" | `AppColor.failure` |
| Code token colours in Reading view | `AppColor.codeKeyword`, `.codeString`, `.codeNumber`, `.codeComment` |

Add a role when a second view needs the same fill. Do not add one for a single use of a system colour.

## Type (`AppFont`)

Note: `noteTitle 30 bold`, `noteHeading 20 semibold`, `noteBody 16`; Reading view `readingTitle 36 bold`, `readingHeading 22 semibold`, `readingBody 17`. Interface: `welcomeTitle 28 bold`, `welcomeBody 14`, `windowTitle 15 semibold`, `cardTitle 14 semibold`, `panelField 17`, `searchField 15`, `uiBody 13`, `uiEmphasis 13 semibold`, `cardPreview 12.5`, `cardPreviewEmphasis`, `caption 11.5`, `label 11 semibold` (section labels), `keyCap 11 medium`, `code 12 mono`. The Editor's own text follows the Editor font setting and `EditorMetrics` scales, which give the same sizes at 16 pt.

## Spacing (`AppSpacing`)

`tiny 2` (stacked lines of text), `xsmall 4` (inside a row, around a list), `compact 6` (row padding, table cells), `small 8` (default gap and padding), `medium 10` (block padding), `comfortable 12` (inner card padding, gap between sections), `snug 14` (card grid gap), `regular 16` (sections, card padding), `spacious 20` (panel field padding), `large 24` (Home and Search padding), `wide 32` (Welcome), `roomy 40` (above the Note title), `editorMargin 56` (Editor side margin, also `EditorMetrics.textInset`).

- `0` is fine (`VStack(spacing: 0)`). Any other number is a token.
- Never do arithmetic on a token (`AppSpacing.xsmall + 2`). Add a step instead.
- Text inside the Editor uses `EditorMetrics.textInset`, the same in the Properties form and Reading view, so everything lines up with the text.

## Radii (`AppRadius`)

`tiny 6` (key caps), `row 8` (Outline row, tables, code blocks, callouts, tabs, Link suggestions), `field 10`, `inner 12` (Backlink card, panel row, Recent Pack row), `card 14` (cards, search bar, Properties block, Search result), `panel 18` (Recent Packs panel), `popover 22` (Quick Switcher, Palette), `window 26`. Chips and pills use `Capsule()`. Inner radius = outer radius minus inset.

## Opacity (`AppOpacity`)

`emphasized 0.8` and `subdued 0.7` for secondary text. `disabled 0.45` for a command that cannot run or a missing Pack. `unresolved`, `highlight` and `callout` feed the fill roles above; use the role, not the number.

## Metrics (`EditorMetrics`)

Note column (`maxTextWidth 720`, Properties name column 150 and row 32), window (`sidebarWidth 248`, `inspectorWidth 320`, smallest 1100 × 700, default 1440 × 900), Home cards (height 212, edge 3, footer 38, fade from 0.72, three columns, `labelDot 7`, `searchBarHeight 48`), Search (`resultKindWidth 58`), panels (`panelWidth 640`, top inset 110, shadow 35 / 28, list up to 420), Welcome (780 × 500, Recent Packs 300, icon 104 with radius 24, buttons 240, text 320), Settings width 640, and the Editor's text scales, panes and Link suggestion sizes.

- A fixed width or height in a view comes from here. `.infinity` and `0` are fine.
- A new screen with a fixed size adds its constants here, not in a per-view `Constants`.

## Motion (`AppMotion`)

`quick 120 ms` for presses and small changes, `standard 200 ms` for panels and selection moving, `dismissDelay 100 ms` for letting a panel close before its command runs.

- Every animation uses an `AppMotion` duration. Never `.easeInOut`, `.spring` or `duration: 0.2` in a view.
- Search results, switchers and the Command Palette do not animate. Speed wins.
- Never animate a view's first layout. Respect Reduce Motion.

## Controls

- Style controls with `ButtonStyle` and `ToggleStyle`; never rebuild one from shapes. It loses the keyboard, focus and VoiceOver.
- One primary button (`.borderedProminent`) per sheet or page.
- Use system materials (`.bar`, `.regularMaterial`) for chrome. Panels and the Recent Packs panel use `.regularMaterial`; the Welcome window uses `.thinMaterial`.

## Check

```
cd Modules/DotKit && xcrun swift test --filter DotDesignTests
```

The scan skips comments and everything from the first `#if DEBUG` or `#Preview` in a file. It allows `0`, system semantic colours (`.secondary`, `.separator`, `Color.accentColor`, `NSColor.textColor`), `Task.sleep(for: .seconds(...))` in snapshot launch hooks, and integer constants such as a nesting depth.

## Screens

The screens follow the `dot_design` project ([ADR 0012](../adr/0012-adopt-the-dot-design-project.md)). Build it and run it with `-DotScreen home|note|reading|backlinks|search|switcher|palette|settings` to see each one.
