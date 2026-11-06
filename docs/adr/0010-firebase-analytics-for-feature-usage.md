# 0010 — Firebase Analytics for feature usage

Date: 05/11/2026. Status: accepted (the user chose analytics with no opt-out on 05/11/2026).

## Context

`ARCHITECTURE.md` said Dot has no network. The user wants to know which features people use and which they don't.

## Decision

- **Dot sends usage events to Firebase Analytics** (project `dot-notes-app`). The SDK lives in the app target only (`src/App/Usage.swift`); DotKit stays free of it.
- **Events carry no Pack content.** Never Note text, names, paths, Tags or search queries. Counts are sent as buckets (`0-9`, `10-99`, …).
- **One event name per feature**: `use_<AppCommand>` for every command, wherever it runs from (menu, shortcut, Command Palette, toolbar). A feature that never shows up in the Events report is unused. Other events: `pack_opened`, `note_created`, `note_duplicated`, `note_renamed`, `note_moved`, `note_deleted`, `search_result_opened`, `quick_switcher_opened_note`, `tag_opened`, and `screen_view` for sidebar panes, Reading View and Settings tabs.
- **No opt-out.** The user chose this.
- **Release builds send; Debug builds don't.** A Debug build sends only when launched with `-FIRDebugEnabled` (shows in Firebase DebugView). In Release, any `-Dot…` launch argument (snapshots, scripted or profiling runs) turns analytics off. UI tests run Debug without the flag, so test runs never reach the real project.
- **No config, no analytics.** `GoogleService-Info.plist` is ignored by a global gitignore; when the bundle lacks it, Dot skips Firebase rather than crash.
- **The sandbox gains `com.apple.security.network.client`.**

## Consequences

- The privacy policy and Mac App Store privacy labels must declare usage data and identifiers.
- Removing analytics later means deleting `Usage.swift`, its call sites, the package and the entitlement.
