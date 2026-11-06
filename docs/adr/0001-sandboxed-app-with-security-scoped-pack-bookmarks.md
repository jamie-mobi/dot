# 0001 — Sandboxed app with security-scoped Pack bookmarks

Date: 27/10/2026. Status: accepted for Milestone 1; revisit before the first release.

## Context

`ARCHITECTURE.md` left open whether Dot ships in the Mac App Store (sandboxed) or with Developer ID outside it (no sandbox). Milestone 1 has to open a Pack the user picks and reopen it on the next launch, so the choice shapes the Data layer now.

## Decision

Dot runs in the App Sandbox with the `com.apple.security.files.user-selected.read-write` and `com.apple.security.files.bookmarks.app-scope` entitlements. The user grants a Pack through the folder picker. Dot stores a security-scoped bookmark for it in its own preferences and resolves the bookmark on launch. All access to the Pack goes through the `PackAccessGranting` protocol, so the sandbox detail stays in Data.

## Consequences

- Both distribution routes stay open: a sandboxed app can still ship with Developer ID; an unsandboxed one cannot enter the App Store later without this work.
- Dot can read only Packs the user picked. A symlink out of the Pack cannot be followed, which matches the deliberate constraint "never follows a link out of the Pack". Milestone 1 skips symlinks in the Folder tree.
- A stale bookmark (the Pack moved) is refreshed when it still resolves, and otherwise sends the user back to the welcome screen.
- Tests and acceptance runs do not need bookmarks: they open a fixture Pack in a temporary folder directly.
