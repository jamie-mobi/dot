# 0012. Adopt the opal_design project as Opal's interface

Date: 06/11/2026

## Status

Accepted. Replaces the M9 layout where it differs; ADR 0009 (accent) still holds.

## Context

A separate SwiftUI design project (`opal_design`) shows Opal's interface with mock data: its own tokens, a Home of card sections, a Search screen, in-window panels for the Quick Switcher and Command Palette, a text-tab Inspector, a new Welcome window and Settings. It is the design to build. Opal's M9 interface differed: a sidebar with Files, Search and Tags panes, a floating detail panel, sheets for the panels, a status bar under the Note.

## Decision

- Use the design project's tokens and views as they are. `OpalDesign` holds its values; views in `src/Presentation` follow its layout and copy.
- The window is a standard `NavigationSplitView` with the native inspector. The sidebar always shows Starred, the Folder tree and Recent Notes.
- The detail column shows one `VaultDestination`: Home, Search or the open Note. `NavigationService` owns it, so Back and Forward work across all three.
- The Quick Switcher, Command Palette and Template picker are panels over a scrim inside the window, not sheets.
- Features the design does not show keep working, placed where the design has room: Vault Tags are the Search screen's Any Tag filter; the Note's word count and dates sit under the Outline; tabs, split view, the conflict banner and Tag suggestions stay; "Not Saved" shows in the toolbar only when a save fails.
- Two departures are deliberate: the Command Palette stays on ⇧⌘P (the design brief keeps ⌘P for Print), and the title and Properties above the Editor stay put while the text scrolls (Reading view scrolls them with the text).

## Consequences

- `SidebarPane` and `-OpalSidebarPane` are gone. The Quick Switcher no longer shows a preview of the selected Note.
- The default line width is Readable (720 pt) and Settings offers Fill the window or Readable.
- The window's smallest size is 1100 × 700, and the Welcome window is 780 × 500.
