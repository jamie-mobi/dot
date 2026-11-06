# 0008 — One service graph per window

Date: 29/10/2026. Status: accepted (the user said go on 29/10/2026).

## Context

M5-12 asks for more than one window, each on its own Pack, with its own Index, Link map, tabs and history. A Pack must not be open in two windows at once, and windows come back at launch. Until now there was one `ServiceGraph`, built at launch and reached through `AppDependencies.shared`.

## Decision

- **One graph per window.** Each window has a `ServiceGraph` and its own `PackService`, Index, Link map, Notes and navigation. `WindowRegistry` (DotCore) creates a graph for each window id through a factory, keeps the ordered list of window ids through `WindowListStoring`, and closes a graph when its window closes. To close one, it saves the Notes, closes the Pack and forgets the window, except when the app is quitting.
- **Settings are shared.** One `SettingsService` serves every graph and pushes Dot's settings into every Pack (see the refactor before this ADR). The Settings window shows the Obsidian settings of the window that was active last.
- **A Pack is open in at most one window.** Before Open Pack… or Create Pack…, `OpenPackUseCase` compares standardized folder URLs, with symlinks resolved. If another window shows that Pack, it comes to the front. If this window has no Pack, the Pack opens here. Otherwise it opens in a new window.
- **Each window remembers its own Pack.** The window's location store uses a key with its id. The first window falls back to the old single key, so an existing install reopens its Pack.
- **Dot restores windows itself.** SwiftUI's window restoration is off (`.restorationBehavior(.disabled)`). At launch the first saved window opens, and it opens the others. Acceptance runs with `-DotPackPath` open exactly one window and restore nothing.
- **Menus act on the key window.** Each window publishes its graph as a focused scene value. `DotCommands` reads it, and with no window every command except Settings… is disabled.

## Consequences

- Two windows never share Notes, an Index, a Link map, tabs or history. Every window builds its own Index store, keyed by the Pack, as one window does today.
- `AppDependencies.shared` keeps only app-wide values: launch arguments, preferences, `SettingsService` and `WindowRegistry`. A view that is missing its window's graph falls back to an empty placeholder graph with no Pack, never to another window's graph.
- SwiftUI's own window restoration is off. Dot restores which windows were open, their Packs, and (M6-04) each window's panes, split share and frame, from `WindowState` saved per window id beside the window list.
