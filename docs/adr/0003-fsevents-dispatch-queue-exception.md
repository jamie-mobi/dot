# 0003 — The Pack watcher uses FSEvents with one `DispatchQueue`

Date: 27/10/2026. Status: accepted.

## Context

Story M2-08 needs Dot to see files that Obsidian, git or a sync tool add, remove or change while the Pack is open. `CLAUDE.md` bans `DispatchQueue`: state lives in `@MainActor` services and async work uses Swift concurrency.

macOS reports file changes through FSEvents. Since macOS 13 the only supported way to receive FSEvents callbacks is `FSEventStreamSetDispatchQueue`; the run-loop API is deprecated. The alternatives were weighed:

- **Polling** the folder from a `Task` keeps the rule but is slow to notice a change and costs a full listing of a 10,000-Note Pack every few seconds.
- **`NSFilePresenter`** uses an `OperationQueue`, but it only hears about changes made through file coordination. Obsidian, git and most sync tools do not coordinate, so it misses the changes this story is about.
- **`DispatchSource` file-system objects** also need a queue and watch one file descriptor each, not a tree.

## Decision

`FSEventsPackWatcher` (Data) creates one private serial `DispatchQueue` and hands it to `FSEventStreamSetDispatchQueue`. That is the only `DispatchQueue` in Dot. The callback does no work on the queue beyond turning paths into `NotePath`s and yielding them into an `AsyncStream`. Everything after that is Swift concurrency on the main actor (`PackService`).

## Consequences

- Changes made outside Dot reach the tree, the open Note and the Link map within about a second (latency 0.3 s).
- The exception is confined to one Data file. Any other `DispatchQueue` is still a review failure.
- Dot's own saves also produce events. `NoteService` ignores an event whose disk text equals what it last wrote, so a save never reloads the Note or raises a conflict.
- Hidden paths (`.obsidian/`, `.git/`, `.trash/`) are dropped in the watcher.
