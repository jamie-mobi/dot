# 0013. Rename the app to Dot and Vault to Pack

Date: 06/11/2026

## Status

Accepted.

## Context

The app was called Opal, and the folder it opens was called a Vault, the same word Obsidian uses. The app is now Dot, and Dot's word for that folder is Pack. Builds already installed on a Mac keep their settings, saved folder bookmarks and Index inside the app's sandbox container, which macOS names after the bundle ID. Firebase's `GoogleService-Info.plist` is also registered to the bundle ID.

## Decision

- Every name in code, docs, tests, fixtures, paths and UI copy changes: Opal → Dot, Vault → Pack. The Xcode project, schemes, targets, the `DotKit` package and its `DotCore` and `DotDesign` modules use the new name.
- The bundle ID stays `com.jamielesouef.Opal`. The log subsystems match it. The sandbox container, settings, bookmarks and Firebase registration carry on.
- Where text means Obsidian's own concept, it still says "Obsidian vault", and `ObsidianVaultSettingsParser` keeps its name.
- `UserDefaultsPackLocationStore` moves values saved under `lastVaultBookmark…` and `recentVaults` to `lastPackBookmark…` and `recentPacks` the first time it runs.

## Consequences

- The bundle ID still says Opal. Changing it later starts a fresh container and needs a new Firebase app.
- The Index moves from `Application Support/Opal/Indexes` to `Application Support/Dot/Indexes` and is rebuilt once. The old folder stays in the container until it is deleted by hand.
- The "Reopen Packs at launch" setting and the accent choice fall back to their defaults once, because their stored names changed.
- Analytics events named `vault_*` are now `pack_*`, so feature usage starts a new series.
- Xcode Cloud workflows must be pointed at `Dot.xcodeproj` and the `Dot` scheme in App Store Connect.
