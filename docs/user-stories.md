# Opal user stories

Stories for Opal v1, grouped into milestones. Vocabulary follows [GLOSSARY.md](../GLOSSARY.md). The reference screens of Obsidian are indexed in [screens/README.md](screens/README.md); the design is set by [design-brief.md](design-brief.md).

The user is someone who writes a lot and links their Notes. Some already keep an Obsidian Vault.

Each story has acceptance criteria. A story is done when its criteria pass in tests (Domain, parsers, Data and Services) or in a run against a fixture Vault copied to a temporary folder (Presentation).

## Milestones

| Milestone | Goal | Stories |
| --- | --- | --- |
| **M1 — Open a Vault and write a Note** (built 27/10/2026) | Open an existing Obsidian Vault or a new one, browse it, and write in a Note safely | M1-01 … M1-11 |
| **M2 — Links** (built 27/10/2026) | Follow Links, see Backlinks, find Notes by name | M2-01 … M2-10 |
| **M3 — Find** (built 27/10/2026) | The Index, full-text Search, Tags, unlinked mentions | M3-01 … M3-06 |
| **M4 — Rich Editor** (built 28/10/2026) | Live Markdown, Reading view, Properties, Embeds, checkboxes, images, lists | M4-01 … M4-07 |
| **M5 — Daily work** (built 29/10/2026) | Daily Notes, Templates, rename and move with Link updates, delete, Command Palette, tabs and split view, Settings, windows | M5-01 … M5-12 |
| **M6 — Polish** (built 29/10/2026) | The app icon and one design system, the gaps left by M5 (split divider, restoring layout, Reading view font, recent Vaults), and the Editor and Property items from Later | M6-01 … M6-09 |
| **M7 — Gaps** (built 29/10/2026) | Close the gaps M6 left: the split at the default window size, folding the YAML again, Vault-wide Property types in the form, short folder paths for recent Vaults | M7-01 … M7-04 |
| **M8 — Finishing touches** (built 03/11/2026) | Build what is left from Later: Heading and Block suggestions, custom shortcuts, any installed font, a General Settings tab | M8-01 … M8-07 |
| **M9 — Redesign** (built 03/11/2026) | The new look: frosted window, opal-rose accent with a System option, Folder colours, Starred and Recent Notes, Vault home cards, and every screen restyled | M9-01 … M9-15 |
| **M10 — After the redesign** | Close what M9 left: Match Case and a Text/Properties scope in Search, Embed wording in Backlinks, a first Index of 10,000 Notes inside its budget, and adding a Block id from `[[#^` | M10-01 … M10-04 |

Out of scope for v1: Graph, Canvas, plugins, sync, publishing, iOS and iPadOS, collaboration.

---

## M1 — Open a Vault and write a Note

### M1-01 Open an existing Vault
As a user with an Obsidian Vault, I want to open its folder in Opal, so that I can write in the Notes I already have.

- On first launch, with no Vault remembered, Opal shows a welcome screen with **Open Vault…** and **Create Vault…**. No account, no sign-in.
- **Open Vault…** shows the macOS folder picker. Choosing a folder opens it as the Vault.
- Any folder works, with or without `.obsidian/`. Opal never creates `.obsidian/`, and never writes inside it.
- While the Vault is read, the window shows progress, not an empty tree.
- If the folder cannot be read, Opal says so and offers **Open Vault…** again.

### M1-02 Create a new Vault
As a new user, I want to create an empty Vault, so that I can start writing without setting anything up.

- **Create Vault…** shows a save panel for a new folder name and place.
- Opal creates the folder and opens it. It writes nothing else into it.
- If the folder already exists, the panel's own replace prompt applies; Opal opens the existing folder and never deletes its contents.

### M1-03 Reopen the last Vault
As a returning user, I want Opal to open the Vault I used last, so that I can carry on where I stopped.

- On launch Opal reopens the last Vault without asking.
- If that folder has moved or been deleted, Opal shows the welcome screen with a message naming the folder, not an error alert.
- **File ▸ Open Vault…** (⇧⌘O) switches to another Vault at any time. Unsaved edits are saved first.
- Opal remembers the Vault outside the Vault (the app's preferences), never in a file inside it.

### M1-04 Browse the Folder tree
As a user, I want to see the Vault's Folders, Notes and Attachments in the sidebar, so that I can find a Note by where I put it.

- The sidebar shows the Vault's name and a tree of its Folders, Notes and Attachments at any depth.
- Folders come first, then files. Each group is in name order, the way Finder sorts (`Note 2` before `Note 10`, case ignored).
- A Note shows its name without `.md`. An Attachment shows its full file name.
- Hidden items are not shown: any name starting with `.` (such as `.obsidian`, `.trash`, `.git`).
- Folders can be expanded and collapsed. The sidebar can be hidden.

### M1-05 Open a Note
As a user, I want to select a Note and read and edit its text, so that I can write.

- Selecting a Note in the sidebar opens it in the Editor. The window title shows the Note's name; the subtitle shows its Folder.
- The Editor shows the file's Markdown exactly, frontmatter included.
- Selecting an Attachment does not open it in the Editor; it shows its name and an **Open in Default App** button.
- If the file cannot be read (permissions, not UTF-8), the Editor says so and offers to try again. Opal never writes to that file.
- With no Note selected, the Editor shows a calm empty state with **New Note** (⌘N).

### M1-06 Edit and save a Note
As a user, I want my edits saved without thinking about it, so that I never lose work and never press Save.

- Edits are saved automatically shortly after typing stops, when another Note is opened, when the Vault is switched, and when Opal quits. ⌘S saves at once.
- The saved file holds exactly the text in the Editor. Opal does not change line endings, trailing whitespace, frontmatter or anything else.
- Opening a Note and not editing it never writes the file, and never changes its modification date.
- Typing is not changed behind the user's back: no smart quotes, smart dashes or automatic spelling correction in M1.
- Writes are atomic: a crash mid-save leaves the old file or the new file, never half of one.
- Undo and redo work for the open Note.

### M1-07 Create a Note
As a user, I want to create a Note in one keystroke, so that I can write something down now.

- **File ▸ New Note** (⌘N) creates `Untitled.md`, or `Untitled 1.md`, `Untitled 2.md` … if that name is taken, and opens it in the Editor.
- Where it goes follows Obsidian's `.obsidian/app.json` when present: `newFileLocation` `root` → the Vault root; `folder` → `newFileFolderPath` (created if missing); `current` → the Folder of the open Note. With no settings, the Vault root.
- The new Note is empty. It appears in the sidebar and is selected.

### M1-08 Create a Folder
As a user, I want to create a Folder, so that I can organise my Notes.

- **File ▸ New Folder** (⇧⌘N) creates `Untitled` (or `Untitled 1` …) in the Folder of the selected item, or the Vault root.
- The Folder appears in the sidebar.

### M1-09 Reveal in Finder
As a user, I want to see a Note's file in Finder, so that I can use other apps on it.

- The sidebar context menu has **Reveal in Finder** for every item, and **Open in Default App** for Attachments.

### M1-10 Empty Vault
As a user who just created a Vault, I want to know what to do next.

- A Vault with no Notes shows an empty sidebar message and the Editor's **New Note** empty state.

### M1-11 Never overwrite a change made elsewhere
As a user who also uses Obsidian, git or a sync tool, I want Opal never to overwrite a change it did not see, so that my Vault stays the source of truth.

- Before saving, Opal compares the file on disk with the text it last loaded or saved.
- If they match, it saves.
- If the file changed on disk and the Note has unsaved edits, Opal does not save. The Editor shows that the Note changed on disk, with **Keep My Version** (writes the edits) and **Use Version on Disk** (drops the edits and loads the file).
- If the file was deleted while open, saving creates it again with the Editor's text.
- **File ▸ Reload Vault** (⌘R) reads the tree again. (Watching the Vault for changes as they happen is M2-07.)

---

## M2 — Links

Each acceptance line starts with how it is checked: `[unit]` a Swift Testing test, `[snap]` a screenshot of the running app on a copy of the `Garden` fixture Vault, `[manual]` a person must try it.

The Link map in M2 is held in memory, built from the files after the Vault opens. It is not the Index (M3-01): nothing is stored, so there is nothing to delete or rebuild.

### M2-01 Read the Links in a Note
As a user, I want Opal to understand the Links I write in Obsidian syntax, so that every later story can follow, list and suggest them.
Screens: `obsidian-06-note-source-mode.png`
Acceptance:
- [unit] The parser finds `[[Note]]`, `[[Note|alias]]`, `[[Note#Heading]]`, `[[Note#^block]]`, `[[Folder/Note]]` and `![[Embed]]`, with their ranges in the text.
- [unit] It finds Markdown Links `[text](path.md)` and `[text](My%20Note.md)`. A Markdown Link to `http:` or `mailto:` is not a Link.
- [unit] It ignores Links inside fenced code blocks, inline code and frontmatter.
- [unit] It finds Headings (`#` to `######`, outside code) and Block ids (`^id` at the end of a line).
- [unit] It reads `aliases` from frontmatter as a list or a single string. Other Properties wait for M4.
Status: done

### M2-02 Resolve a Link to its target
As a user, I want `[[Soil]]` to find `Soil.md` wherever it lives, the way Obsidian does, so that my existing Links work.
Depends: M2-01
Acceptance:
- [unit] Order: exact path from the Vault root, then path relative to the linking Note, then the Note name anywhere in the Vault. When names clash, the shortest path wins, then name order.
- [unit] Case is ignored. `.md` may be left out.
- [unit] An Alias resolves when no Note has that name (`[[Dirt]]` → `Soil.md`).
- [unit] `[[seedlings.png]]` resolves to an Attachment.
- [unit] A Link that matches nothing is an Unresolved Link.
Status: done

### M2-03 Follow a Link (⌘-click)
As a user, I want to ⌘-click a Link to open its target, so that I can move through my Notes.
Screens: `opal-m2-01-links-styled.png`
Depends: M2-02
Acceptance:
- [snap] Links show in the accent colour. The text itself never changes.
- [manual] ⌘-click on a Link opens its target. On a Heading or Block Link, the Editor scrolls to that line and puts the cursor there.
- [manual] A Link to an Attachment opens it in its default app.
- [manual] A plain click places the cursor as usual. The pointer is a hand only while ⌘ is held over a Link.
Status: done

### M2-04 Unresolved Links
As a user, I want to see which Links have no Note yet, and create it by following the Link.
Screens: `opal-m2-01-links-styled.png`
Depends: M2-03
Acceptance:
- [snap] An Unresolved Link shows fainter than a resolved Link (`[[Ideas That Do Not Exist Yet]]` in `Welcome`).
- [unit] Following it plans a new Note: a bare name goes where M1-07 places new Notes; a name with a Folder (`[[Ideas/New]]`) goes in that Folder.
- [manual] The new Note opens and appears in the sidebar. Its Link now shows as resolved.
Status: done

### M2-05 Backlinks
As a user, I want to see the Notes that link to the open Note, each with the line in context, so that I can see how it connects.
Screens: `obsidian-08-backlinks-and-unlinked-mentions.png`, `opal-m2-02-inspector-backlinks.png`
Depends: M2-02
Acceptance:
- [unit] `Soil` has Backlinks from `Gardening Basics`, `Tomatoes` (two Links) and `The Soil Book`. A Link through an Alias counts.
- [snap] The inspector (⌥⌘0, toolbar button) shows Backlinks grouped by Note, with each line in context and the count.
- [manual] Clicking a Backlink opens that Note at the line.
- [unit] After the open Note is saved, the Link map updates; Backlinks of other Notes change to match.
- [snap] With no Backlinks, the section says “No Backlinks”.
Status: done

### M2-06 Outgoing Links and outline
As a user, I want to see what the open Note links to and its Headings, so that I can jump around a long Note.
Screens: `obsidian-09-outgoing-links-pane.png`, `obsidian-12-outline-pane.png`, `opal-m2-03-inspector-outgoing.png`, `opal-m2-04-inspector-outline.png`
Depends: M2-05
Acceptance:
- [snap] The inspector has three sections in a segmented control: Backlinks, Outgoing, Outline.
- [snap] Outgoing lists each Link target once, Unresolved ones fainter.
- [snap] Outline lists Headings indented by level.
- [manual] Clicking an outline row scrolls the Editor to that Heading. Clicking an Outgoing row follows the Link.
Status: done

### M2-07 Quick Switcher (⌘O)
As a user, I want to open any Note by typing part of its name or Alias, so that I never hunt in the tree.
Screens: `obsidian-07-quick-switcher.png`, `opal-m2-05-quick-switcher.png`
Depends: M2-02
Acceptance:
- [unit] Fuzzy match: the letters of the query, in order, in the name, path or Alias. A match at the start of a word ranks higher; a name match beats a path match.
- [unit] `dirt` finds `Soil` through its Alias (Obsidian misses this by default).
- [unit] With an empty query, recent Notes come first, then the rest by name. Recent Notes are kept in Opal's preferences, never in the Vault.
- [snap] A panel over the window: a search field and a list with name, Folder, and the Alias when it matched.
- [manual] ↑ ↓ move, Return opens, Esc closes. With no match, Return creates a Note with the typed name (placed as in M1-07).
- Later: ⌘Return opens in a new tab, when tabs exist (M5-06).
Status: done

### M2-08 Changes from outside
As a user who also uses Obsidian, git or a sync tool, I want Opal to show their changes without ⌘R.
Depends: M2-05
Acceptance:
- [unit] Files added, removed or changed outside Opal appear in the tree within a second (FSEvents, [ADR 0003](adr/0003-fsevents-dispatch-queue-exception.md)).
- [unit] An open Note with no unsaved edits reloads with the text on disk.
- [unit] An open Note with unsaved edits is not touched; saving then follows M1-11.
- [unit] Opal's own saves cause no reload and no conflict.
- [unit] Changes in hidden Folders (`.obsidian/`, `.git/`) are ignored.
- [unit] The Link map updates for each changed Note.
Status: done

### M2-09 Link suggestions (`[[`)
As a user, I want a list of Notes while I type a Link, so that I link without spelling the name exactly.
Screens: `obsidian-14-link-suggestions.png`, `opal-m2-06-link-suggestions.png`
Depends: M2-07
Acceptance:
- [unit] Typing `[[` and a query lists Notes and Aliases by the M2-07 match, plus Unresolved targets already used in the Vault.
- [snap] The list shows under the cursor, like the system completion list.
- [manual] ↑ ↓ choose, Return or Tab inserts, Esc closes. The insert is one undo step.
- [unit] The inserted Link is the shortest path that resolves to the chosen Note; an Alias inserts `[[Note|Alias]]`; `useMarkdownLinks: true` inserts `[Name](path.md)` with spaces as `%20`.
- Later: `#` Headings and `^` Blocks of the chosen Note inside `[[` (now M8-01 and M8-02).
Status: done

### M2-10 Back and forward
As a user who follows Links, I want to go back to the Note I came from.
Depends: M2-03
Acceptance:
- [unit] Opening a Note (by Link, tree, Quick Switcher or Backlink) pushes the last Note on a back list and clears forward.
- [snap] Toolbar back and forward buttons, enabled only when there is somewhere to go.
- [manual] ⌘[ and ⌘] go back and forward.
Status: done

## M3 — Find

The Index is a SQLite database read and written through GRDB ([ADR 0004](adr/0004-index-in-sqlite-with-grdb.md)). It lives in Opal's Application Support folder, one per Vault, never in the Vault. It holds only what Opal can read again from the files.

### M3-01 Keep an Index of the Vault
As a user with a big Vault, I want Opal to remember what it read, so that reopening the Vault is fast.
Depends: M2-08
Acceptance:
- [unit] The Index stores, per Note: path, modification date, size, parsed Links, Headings, Blocks, Aliases, Tags, and the text for search.
- [unit] Opening a Vault compares each Note's date and size with the Index and reads only the Notes that changed, were added or were removed.
- [unit] Deleting the Index folder loses nothing: the next open rebuilds it with the same content.
- [unit] An Index with an older schema version is deleted and rebuilt.
- [unit] Changes from outside (M2-08) and Opal's own saves update the Index.
- [unit] Tests and acceptance runs point the Index at a temporary folder (`-OpalIndexFolder`).
- [snap] While the Index is built, the sidebar foot shows “Indexing 120 of 2,000 Notes…”.
Status: done

### M3-02 The Link map reads the Index
As a user, I want Backlinks ready as soon as the Vault opens, without Opal reading every Note again.
Depends: M3-01
Acceptance:
- [unit] `LinkService` builds the Link map from the parsed Notes in the Index; it reads no Note file when nothing changed.
- [unit] All M2 Link tests still pass.
Status: done

### M3-03 Tags
As a user, I want Opal to know my Tags, so that I can find Notes by topic.
Depends: M3-01
Acceptance:
- [unit] Tags come from `#tag` in the body (not in code, not in a Heading's `#`, not `#123`, not a URL fragment) and from the `tags` Property as a list, an inline list or one value.
- [unit] Tags nest by `/`: `#garden/harvest` counts for `garden` and `garden/harvest`. Case is ignored when counting; the first spelling seen is shown.
- [snap] The sidebar has a Tags section: a tree of Tags with Note counts (`obsidian-10`).
- [manual] Choosing a Tag searches for `tag:#name`.
- Later (with M4-03 Properties): the open Note's own Tags in the inspector, which the design brief lists.
Status: done

### M3-04 Search (⇧⌘F)
As a user, I want to find any word in my Vault, so that I can find a Note I half remember.
Screens: `obsidian-13-search.png`
Depends: M3-01, M3-03
Acceptance:
- [unit] The query parser reads words, quoted phrases, `path:`, `file:`, `tag:` and `-word` (exclude). Unknown operators are searched as words.
- [unit] All words must match (AND). Results are grouped by Note, best first, with up to 3 lines in context per Note and the matched words marked.
- [unit] Search works on a 10,000-Note Index in under 100 ms.
- [snap] ⇧⌘F shows Search in the sidebar, above the Folder tree; results update as you type.
- [manual] Clicking a result opens the Note at that line.
- Later (with M4-03 Properties): `[property:value]` search, which the design brief lists.
Status: done

### M3-05 Unlinked mentions
As a user, I want to see Notes that mention this Note without linking it, so that I can link them.
Screens: `obsidian-08-backlinks-and-unlinked-mentions.png`
Depends: M3-04
Acceptance:
- [unit] For the open Note, the Index finds other Notes whose text contains its name or an Alias as whole words, outside code and outside existing Links.
- [snap] The Backlinks tab shows “Unlinked mentions” below the Backlinks, with the line in context.
- [unit] **Link** asks first, then rewrites only that mention to `[[Name]]` (or `[[Name|Alias]]`), writes that Note atomically, and changes nothing else in it.
Status: done

### M3-06 Large Vaults
As a user with 10,000 Notes, I want Opal to stay fast.
Depends: M3-02, M3-04
Acceptance:
- [unit] A generated 10,000-Note Vault: first index under 20 s, reopen with no changes under 1 s, Search under 100 ms (Release build, this Mac).
- [manual] Typing in a 1 MB Note does not stutter (open-Note parsing is off the main actor since the 27/10/2026 review).
Status: done (measured 27/10/2026, Release: first index 5.6 s, reopen 0.54 s, Search 20 ms; the [manual] typing check is yours)

## M4 — Rich Editor

Styling is a view of the text, never a change to it. The Editor stays a plain-text `NSTextView` on TextKit 2 ([ADR 0002](adr/0002-textkit-2-editor.md)): fonts and colours are text storage attributes, which change neither `string` nor the undo stack. Opal writes a Note only when the user edits it (M4-03, M4-05 and M4-06 are edits). The styled ranges are computed with the open Note's Links, off the main actor for large Notes (the 27/10/2026 review), and the Editor maps each style kind to attributes in one place (the 28/10/2026 review). The Editor styles only the text near what is on screen (10,000 characters either side) and styles more as you scroll, so a 1 MB Note costs about 7 ms per restyle instead of 1.3 s.

### M4-01 Live Markdown
As a writer, I want the Markdown styled as I type, so that the Note reads well while I write it.
Screens: `obsidian-03-note-live-preview.png`
Depends: M2-06, M3-03
UX: Marks fade but never hide, so the text never reflows when the cursor moves. Only their colour changes, faint elsewhere and full strength on the cursor's line. The toggle is in the View menu, above Toggle Inspector, with no shortcut. It is kept in Opal's preferences, never in the Vault.
Acceptance:
- [unit] The parser returns style runs for Headings (levels 1–6), bold, italic, bold italic, strikethrough, highlight (`==text==`), inline code, code blocks, quotes, list markers, checkboxes, callouts (`> [!note] Title`), horizontal rules, Links, Embeds and Tags. Each run has a span and a kind, and the marks (`#`, `**`, `` ` ``, `[[`, `]]`) are their own runs.
- [unit] Nothing is styled inside code or frontmatter except as code or frontmatter. Runs never overlap the text's end after an edit.
- [unit] `TextStyleRun` replaces `LinkHighlight`; resolved and Unresolved Links keep their M2-04 colours.
- [snap] A fixture Note with every kind above, light and dark: Headings are larger and bold, code is monospaced on a tinted background, quotes and callouts have a bar, Tags are tinted.
- [snap] Marks are faint on lines without the cursor and full strength on the cursor's line. The text never moves sideways when the cursor changes line.
- [unit] Styling a 1 MB Note does no parsing on the main actor (the M3-06 rule).
- [manual] View › Live Markdown (no shortcut) turns styling off and on. With it off, the Editor is plain text except for Link colours, which ⌘-click needs (M2-04). The choice is kept outside the Vault.
- [manual] Scroll through a 1 MB Note: the text further down is styled as it comes into view.
Status: done (28/10/2026; `MarkdownStyleParserTests`, snapshots `opal-m4-01-*`; the two [manual] lines are yours)

### M4-02 Reading view (⌘E)
As a reader, I want the Note rendered and not editable, so that I can read it without the marks.
Screens: `obsidian-04-note-reading-view.png`
Depends: M4-01
Decided in [ADR 0005](adr/0005-reading-view-in-swiftui.md): native SwiftUI and `AttributedString`, built from the M4-01 parse; no maths.
Acceptance:
- [unit] The rendered blocks come from the same parse as M4-01: Headings, paragraphs, lists, checkboxes, quotes, callouts, tables, code blocks, horizontal rules, Links and Embeds.
- [manual] ⌘E and the toolbar's Editor / Reading control switch views; the scroll position stays on the same Heading. (The snapshot cannot show the toolbar.)
- [snap] Tables have columns and a header row; code blocks have syntax colour for at least Swift, Python, JavaScript, JSON, YAML and shell; callouts show their type's icon and title.
- [snap] `$…$` and `$$…$$` show as maths, or, if ADR 0005 drops maths, as code, with a note in the story.
- [manual] Clicking a Link follows it (M2-03); Heading Links read `Note > Heading`.
- [unit] Reading view never writes the Note.
Status: done (28/10/2026; `MarkdownReadingParserTests`, `CodeTokenizerTests`, `ReadingViewTests`, snapshots `opal-m4-02-*`). Per ADR 0005, maths is not rendered: `$$…$$` blocks show as code and inline `$…$` as written. For you to check [manual]: clicking a Link, and the scroll position when you switch with ⌘E.

### M4-03 Properties
As a user, I want my Note's Properties as a small form, so that I can read and change them without editing YAML.
Screens: `obsidian-03-note-live-preview.png`, `obsidian-11-all-properties-pane.png`
Depends: M4-01
Acceptance:
- [unit] A frontmatter parser reads text, number, checkbox, date, date-and-time and list Properties, and keeps the exact source lines of each one. Unreadable YAML is shown as YAML, never rewritten.
- [unit] Changing one Property rewrites only that Property's lines; every other byte of the Note, including key order, quotes, comments and line endings, is unchanged. Adding a Property appends it; removing one removes only its lines.
- [unit] Types are inferred per Property name across the Vault, from the Index, as Obsidian does (`.obsidian/types.json` is read when present, never written).
- [snap] The form sits above the text, below the Note's name: a row per Property with an icon for its type, an Add Property button, and a way to edit the frontmatter as YAML.
- [manual] The inspector shows the open Note's Tags (from M3-03's Later line).
- [unit] Search reads `[property:value]` (from M3-04's Later line).
- Later: types inferred across the whole Vault from the Index, and `[property:value]` search. Both need Property values in the Index, which means a schema change, so they are a story of their own.
- Later: hide the frontmatter in the Editor while the form shows it. For now the Editor still shows it as faint YAML, and that is where **Edit as YAML** puts the cursor.
Status: done (28/10/2026; `FrontmatterParserTests`, `PropertyServiceTests`, `opal-m4-03-properties.png`). Types come from the value, the name (`tags`, `aliases`) and `.obsidian/types.json`. The inspector has a Tags tab for the open Note. Editing in the form is [manual] and yours to check.

### M4-04 Embeds
As a user, I want Embeds shown inline, so that I can see the embedded Note, image or PDF where it is used.
Screens: `obsidian-03-note-live-preview.png`
Depends: M4-01, M4-02
Acceptance:
- [unit] `![[Note]]`, `![[Note#Heading]]`, `![[Note#^block]]`, `![[image.png]]`, `![[image.png|300]]`, `![[file.pdf]]` and `![alt](image.png)` resolve with the M2-02 rules; the Heading form takes the text up to the next Heading of the same or a higher level.
- [snap] In Reading view ([ADR 0006](adr/0006-embeds-only-in-reading-view.md): never in the Editor, which shows the Embed as styled text), Embeds show below their line: a Note or a Heading’s text in a bordered box with its name, an image at its size or the width given, a PDF as a scrollable page view.
- [snap] An Unresolved Embed shows “‘name’ is not in this Vault” with a create action.
- [unit] An Embed of a Note that embeds itself, directly or through others, stops after one level and says so.
- [manual] Changing the embedded Note elsewhere updates the Embed.
Status: done (28/10/2026; `EmbedTests`, snapshots `opal-m4-04-*`). In the snapshot a PDF shows as a blank page because `cacheDisplay` does not draw PDFKit; check it [manual]. If a Note is already shown higher up, Opal says so instead of embedding it again. Embeds also stop at four levels deep.

### M4-05 Checkboxes
As a user, I want to tick a task with one click, so that I do not have to type the `x`.
Screens: `obsidian-03-note-live-preview.png`
Depends: M4-01
Acceptance:
- [unit] Toggling a checkbox changes only the one character between `[` and `]` (space to `x`, `x` or `X` to space) and nothing else in the line or the Note.
- [snap] With live Markdown on, `- [ ]` and `- [x]` show as checkboxes; done tasks are struck through and faint. Reading view shows the same.
- [manual] Clicking the checkbox toggles it; the toggle is one undo step and is saved like any edit.
- Later: draw a checkbox in place of the `[ ]` brackets in the Editor. In Reading view, clicking a checkbox toggles it as well (`NoteService.toggleCheckbox(onLine:)`).
Status: done (28/10/2026; `CheckboxToggleUseCaseTests`, `opal-m4-05-checkboxes.png`; clicking is [manual] and yours to check)

### M4-06 Paste and drop images
As a user, I want to paste or drop an image into a Note, so that I can add it without the Finder.
Depends: M4-04
Acceptance:
- [unit] The Attachment's place follows `attachmentFolderPath` from `.obsidian/app.json` (Vault root, a named Folder, the Note's Folder, or a subfolder of it) and Opal's own setting when there is no `app.json`.
- [unit] The name is `Pasted image YYYYMMDDHHmmss.png` for a paste and the file's own name for a drop; a name that is taken gets ` 1`, ` 2`… The file is written atomically and never replaces an existing file.
- [unit] The Embed `![[name.png]]` is inserted at the cursor (or the drop point) as one undo step, using the shortest Link form the Vault's `newLinkFormat` asks for.
- [manual] Paste from Screenshot and drag from Finder both work; the image shows in Reading view (M4-04).
Status: done (28/10/2026; `AttachmentUseCaseTests`, `AttachmentServiceTests`). Only image files are attached; other dropped or pasted files keep the Editor's usual behaviour. Paste and drag are [manual] and yours to check: I could not drive the pasteboard or a drag in the running app.

### M4-07 Lists continue on Return
As a writer, I want Return in a list to start the next item, so that I can write lists without typing markers.
Depends: M4-01
Acceptance:
- [unit] Return at the end of, or inside, a list item inserts a new item with the same indent, quote prefix and marker. Numbers count up (`1.` then `2.`, `9)` then `10)`), and a task starts unticked (`- [ ] `).
- [unit] Return on an empty item removes its marker and leaves an empty line, which ends the list.
- [unit] Return outside a list item, or with the cursor inside the marker, is a plain newline.
- [manual] Each Return is one undo step.
Status: done (28/10/2026; `ListContinuationUseCaseTests`; checked in the running app by a scripted Return, typing and Return on a copy of a 13 KB Note)

## M5 — Daily work

Every change to a file in this milestone is one the user starts, and those that touch other Notes (Link updates) are confirmed first unless the user chose otherwise in Settings. Opal never writes `.obsidian/`: it reads `daily-notes.json`, `templates.json` and `app.json`, and keeps its own choices in its preferences. Each multi-file change writes each Note atomically, and a failure partway reports which Notes changed.

### M5-01 Today's Daily Note
As a writer, I want one command to open today's Daily Note, so that I can start writing without choosing a file.
Screens: `obsidian-18-daily-note.png`, `obsidian-25-settings-daily-notes.png`
Depends: M1-07
Acceptance:
- [unit] The Folder, name format and Template come from `.obsidian/daily-notes.json` when it is there, otherwise from Opal's settings (M5-11; default: Vault root, `YYYY-MM-DD`, no Template).
- [unit] The format reads the Moment tokens Obsidian users use: `YYYY`, `YY`, `MM`, `M`, `DD`, `D`, `MMM`, `MMMM`, `ddd`, `dddd`, `[literal]`, and `/` for subfolders (`YYYY/MM/YYYY-MM-DD`). Today's date comes from `Clocking`.
- [unit] When the Note is missing it is created from the Template with `{{date}}`, `{{time}}`, `{{title}}` and `{{date:FORMAT}}` filled in; a missing Template gives an empty Note. An existing Daily Note is opened, never overwritten.
- [snap] Go › Today's Daily Note (⌥⌘D) and a toolbar button (calendar icon) open it.
- [manual] Opening it twice in a day opens the same Note.
Status: done (28/10/2026; `DailyNoteUseCaseTests`, `DailyNoteServiceTests`, `opal-m5-01-daily-note.png`). A Vault without `daily-notes.json` uses Opal's Daily Notes settings (M5-11).

### M5-02 Insert a Template
As a writer, I want to insert a Template at the cursor, so that I can reuse a structure.
Depends: M5-01
Acceptance:
- [unit] The Templates Folder comes from `.obsidian/templates.json` (`folder`), otherwise Opal's settings. Every Note in it, and its subfolders, is a Template.
- [unit] `{{date}}`, `{{time}}`, `{{title}}` (the open Note's name) and `{{date:FORMAT}}`/`{{time:FORMAT}}` are filled in; other text is inserted as it is. Date and time formats come from `templates.json` when set.
- [snap] Edit › Insert Template… (⌥⌘T) shows a searchable list of Templates; Return inserts the chosen one at the cursor as one undo step.
- [snap] With no Templates Folder, the list says where to make one.
Status: done (28/10/2026; `TemplateServiceTests`, `opal-m5-02-insert-template.png`). Pressing Return to insert at the cursor is [manual]: the snapshot shows the list only.

### M5-03 Rename a Note
As a user, I want to rename a Note and keep the Links to it working.
Screens: `obsidian-15-file-context-menu.png`, `obsidian-16-rename-inline.png`
Depends: M3-02
Acceptance:
- [unit] A rename plan lists every Link to the Note (wiki and Markdown, Embeds, with `#Heading`, `#^block` and `|alias`) and the new text of each, keeping its style, subpath and alias. A Link written as a bare name stays a bare name when the new name is still unique, and gets the shortest path when not.
- [unit] The new name may not be empty, contain `/`, `:` or `\`, start with `.`, or clash with another file in the Folder (ignoring case); a case-only rename works.
- [snap] Rename… in the Folder tree's context menu, or Return on a selected Note, edits the name in place.
- [snap] When other Notes link to it, a sheet says "Update Links in N Notes?" with Update, Don't Update and Cancel; a setting (M5-11) can choose always or never.
- [unit] The file is renamed first, then each linking Note is written atomically; the open Note, its tab and the history follow the new path. The Index and Link map are updated.
Status: done (28/10/2026; `RenameUseCaseTests`, `RenameServiceTests`, `opal-m5-03-rename-inline.png`). Settings › Files and Links chooses Ask, Always or Never for the "Update Links" sheet (M5-11). Typing a name, Return and the sheet are [manual].

### M5-04 Rename a Folder
As a user, I want to rename a Folder and keep Links into it working.
Depends: M5-03
Acceptance:
- [unit] Links that name a path inside the Folder are updated as in M5-03; Links by bare name are left alone.
- [snap] Rename… and Return work on Folders as on Notes; expanded Folders stay expanded.
Status: done (28/10/2026; `RenameServiceTests.renamesFolder`, `opal-m5-04-rename-folder.png`). Expanded Folders and the selection follow the new path.

### M5-05 Move a Note or Folder
As a user, I want to move a Note or Folder to another Folder, by drag or menu, and keep Links working.
Depends: M5-03, M5-04
Acceptance:
- [unit] Moving uses the same Link plan as renaming; relative Markdown Links inside the moved Note are rewritten so they still point to the same files.
- [snap] Dragging a row onto a Folder in the tree moves it; Move to… in the context menu shows a Folder picker.
- [unit] A move into the same Folder, into itself or into its own subfolder is refused.
Status: done (28/10/2026; `RenameUseCaseTests`, `RenameServiceTests.moves`, `opal-m5-05-move-to.png`). Moves update Links after the same dialog when other Notes link in; since M5-11 the Update Links setting (Ask, Always, Never) decides for moves too. Drag and drop is [manual].

### M5-06 Duplicate a Note
As a user, I want to duplicate a Note to start a similar one.
Depends: M1-07
Acceptance:
- [unit] Duplicate makes `Name 1.md` (then ` 2`…) beside the original with the same bytes, and opens it.
- [snap] Duplicate is in the Folder tree's context menu and the File menu.
Status: done (28/10/2026; `VaultServiceTests.duplicates`). The context menu and File › Duplicate Note are [manual]; a snapshot can't open a menu.

### M5-07 Delete a Note or Folder
As a user, I want to delete a Note or Folder and be able to get it back.
Depends: M1-04
Acceptance:
- [unit] Deleting moves the item to the macOS Trash (`FileManager.trashItem`); Opal never deletes permanently. Links to it become Unresolved and are not edited.
- [snap] Delete (⌘⌫ in the Folder tree, or the context menu) asks first: "Move “Name” to the Trash?" (with the number of Notes for a Folder).
- [unit] Deleting the open Note closes it and its tabs; the Index and Link map drop it.
Status: done (28/10/2026; `RenameServiceTests.trashes`, `opal-m5-07-delete-folder.png`). Tests move items into a temporary folder instead of the real Trash. ⌘⌫ and the context menu are [manual].

### M5-08 Command Palette (⇧⌘P)
As a keyboard user, I want every command in one searchable list.
Screens: `obsidian-05-command-palette.png`
Depends: M2-07
Acceptance:
- [unit] Every menu command is a palette command with a name, a group (File, Edit, View, Go) and its shortcut; commands that cannot run now are listed but disabled.
- [unit] Matching is fuzzy over the name, recent commands first.
- [snap] ⇧⌘P shows the palette over the window like the Quick Switcher; each row shows the shortcut on the right.
- [manual] Return runs the selected command; Escape closes.
Status: done (28/10/2026; `CommandMatchUseCaseTests`, `opal-m5-08-command-palette.png`). The menus and the palette are built from one list (`AppCommand`), so they cannot drift apart. Folder tree actions (rename, move, delete) stay in the context menu because they act on a row. Return and Escape are [manual].

### M5-09 Tabs
As a user, I want several Notes open in tabs, so that I can move between them.
Depends: M2-10
Acceptance:
- [unit] Tabs are a list of Notes with one selected; each tab keeps its own back and forward history (M2-10) and scroll position.
- [snap] Notes open in the current tab; ⌘Return in the Quick Switcher, ⌘-click on a Link or the Folder tree's Open in New Tab open a new one. ⌘W closes a tab, ⌃Tab and ⌃⇧Tab move between them.
- [unit] Closing the last tab shows the empty Editor (M1-10). Open tabs are remembered per Vault outside the Vault.
Status: done (28/10/2026; `TabListTests`, `QuickSwitcherServiceTests.tabs`, `opal-m5-09-tabs.png`). ⌘-click on a Link still follows it in the current tab (M2-03); Open in New Tab is in the Folder tree and ⌘Return in the Quick Switcher. One Editor shows the selected tab, so switching tabs reloads that Note and restores its scroll position. Shortcuts are [manual].

### M5-10 Split view
As a user, I want two Notes side by side, so that I can write while I read another.
Depends: M5-09
Acceptance:
- [snap] View › Split Right (⌘\) shows a second Editor pane with its own tabs; the focused pane gets new Notes and the inspector follows it.
- [unit] The same Note in both panes shows one text: an edit in one appears in the other, and it is saved once.
- [manual] Closing the last tab of a pane closes the pane.
Status: done (29/10/2026; `EditorPanesTests`, `SplitViewTests`, `opal-m5-10-split.png`, `opal-m5-10-split-same-note-dark.png`). Per ADR 0007, each open Note is one `NoteDocument` that both panes share. The panes split the width evenly: `HSplitView` inside the detail column threw a layout-loop exception, so the divider can't be dragged yet. Reading view (⌘E) applies to both panes. Only the first pane's tabs are remembered between launches. Clicking a pane, ⌘\ and closing a pane's last tab are [manual].

### M5-11 Settings (⌘,)
As a user, I want to set how Opal writes and where it puts things.
Screens: `obsidian-21-settings-editor.png`, `obsidian-22-settings-files-and-links.png`, `obsidian-23-settings-appearance.png`, `obsidian-25-settings-daily-notes.png`
Depends: M5-01, M5-03
Acceptance:
- [snap] A standard Settings window with Editor (font, size, line width, line spacing, spell check, live Markdown), Files and Links (new Note location, Attachment folder, wikilinks or Markdown links, update Links on rename: ask, always, never), Daily Notes (Folder, format with a live preview, Template) and Appearance (system, light, dark).
- [unit] Settings live in Opal's preferences (the `-OpalDefaultsSuite` suite in tests), never in the Vault. Where the Vault's `.obsidian` files set a value, that value wins and the setting says "Set by this Vault's Obsidian settings".
- [manual] Changing a setting applies at once to the open Editor.
UX:
- Flow: Opal › Settings… (⌘,), or Settings… in the Command Palette -> the Settings window opens on the last tab -> each change applies at once -> close with ⌘W. No Save button and no confirmation.
- Surface: the standard Settings window (a place people come back to beside the work), with a toolbar of four tabs: Editor, Files and Links, Daily Notes, Appearance. Grouped `Form` rows.
- States: with no Vault open, Files and Links and Daily Notes show Opal's values and say "Open a Vault to see its Obsidian settings." When the Vault's `.obsidian` sets a value, the control is disabled and shows "Set by this Vault's Obsidian settings" under it. An unknown date format shows the preview as written.
- Words: Font, Size, Line width, Line spacing, "Check spelling while typing", Live Markdown; "Where new Notes go" (Vault root, Same Folder as the open Note, In this Folder), Attachment Folder, "Use Markdown Links" (off writes `[[wikilinks]]`), "Update Links when a Note or Folder is renamed or moved" (Ask, Always, Never); Daily Notes: Folder, Date format with "Today: 2026-10-29", Template; Appearance: System, Light, Dark.
- Access: every row is a native control with a label, so VoiceOver reads the label and value. The tabs are reachable with ⌘, then Tab.
Status: done (29/10/2026; `SettingsServiceTests`, `opal-m5-11-settings-*.png`, `opal-m5-11-editor-style.png`). Files and Links and Daily Notes live in `OpalSettings`, saved as JSON in Opal's preferences. Each key the Vault's `app.json` or `daily-notes.json` sets wins and is marked; `alwaysUpdateLinks: true` means Always. Font offers the four system designs (System, Serif, Rounded, Monospaced) rather than every installed font, on purpose; a full font picker can come later. Editor and Appearance are Opal-only and live in the same preferences suite (`@AppStorage`). Changing an Editor setting rebuilds the Editor, so the caret goes back to the start. Reading view follows the Editor font settings from M6-05. `-OpalAppearance` still wins over the Appearance setting. Settings… is also in the Command Palette. Changing settings live is [manual].

### M5-12 More than one window
As a user with two Vaults, I want each in its own window.
Depends: M5-09
Open decision (ADR before code): one service graph per window. The 28/10/2026 review card "the Index and the Link map follow the Vault from a view" is designed here.
Acceptance:
- [unit] Each window has its own Vault, Index, Link map, tabs and history; two windows on two Vaults do not share state. The same Vault can't be open in two windows at once (the second brings the first to the front).
- [snap] File › New Window (⇧⌘N moves to New Folder… ⌥⌘N) opens the Vault picker; Open Vault… in a window with a Vault opens a new window.
- [unit] Windows and their Vaults are restored at launch.
Status: done (29/10/2026; ADR 0008, `WindowRegistryTests`, `SettingsServiceTests.reachesEveryVault`, `opal-m5-12-new-window.png`, `opal-m5-12-split-default-size.png`). Each window has its own `ServiceGraph`. Open Vault… and Create Vault… open in this window when it has no Vault, bring forward the window that already shows the Vault, and otherwise open a new window. Settings are shared by every window, and the Settings window shows the Obsidian settings of the window that was active last. Opal restores the open windows and their Vaults itself, but not window frames. Acceptance runs with `-OpalVaultPath` open one window and restore nothing. Opening, closing and quitting with several windows are [manual].

## M6 — Polish

The app looks like itself, keeps its layout between launches, and closes the gaps M4 and M5 left. UX notes are added by `improve-loop` before each story is built.

### M6-01 App icon
As a user, I want Opal to have its own icon in the Dock, Finder and the app switcher.
Screens: none. The user asked for a faceted opal stone (crisp flat facets, sharp edges, an opal's play of colour) instead of the source image `docs/design/app-icon-source.png`, which showed an igloo.
Acceptance:
- [snap] `Icon/AppIcon.icon` (Icon Composer: JSON plus SVG layers) compiles with `actool`, and the built app shows it in the default, dark, clear and tinted looks (`ictool` renders each).
- [snap] Every window snapshot from M6 on shows the real icon wherever the system draws it (About, the Welcome view).
Status: done (29/10/2026; xcodebuild build, actool, ictool; opal-m6-01-icon-default, opal-m6-01-icon-dark, opal-m6-01-icon-tinted, opal-m6-01-icon-clear, opal-m6-01-welcome). `Icon/AppIcon.icon` is a faceted opal stone drawn as two SVG layers (`stone.svg`: 17 flat facets, each with its own milky white and pale blue gradient and a flash of teal, green, violet, pink or orange; `edges.svg`: crisp white facet edges and three highlight facets) on a deep indigo gradient, so the glass reads in the default, dark, clear and tinted looks. `project.yml` adds it as a resource with `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`; the built bundle carries `AppIcon.icns`, `Assets.car` with the stone and edges renditions, and `CFBundleIconName` = `AppIcon`. The Welcome view now shows `NSApp.applicationIconImage` at 96 points in place of the `text.document` symbol. The About panel is drawn by the system from the same icon and cannot be captured by the in-app snapshot, so it is not in a snapshot. Checking the Dock, Finder and the app switcher, and the About panel, are yours to check ([manual]). The Welcome snapshot is taken without -OpalVaultPath on an empty defaults suite, in light appearance only (the dark snapshot loses the window background, an existing snapshot limit).

### M6-02 One design system
As a user, I want every screen to use the same colours, spacing, radii and motion.
Acceptance:
- [unit] `OpalDesign` holds the tokens: accent, text and fill roles, spacing, radii, the Editor metrics and animation durations. No view in Presentation uses a literal colour, a spacing number or a radius (a grep check fails the build script if one appears).
- [snap] `design/DESIGN-SYSTEM.md` says which token to use when, with the full snapshot set in light and dark.
- [manual] The accent follows the system accent colour; Opal adds no colour picker of its own.
Status: done (29/10/2026; `OpalDesignTests` (`PresentationTokenCheckTests`, `LiteralScannerTests`, `DesignTokenTests`), `opal-m6-02-*.png`). The "grep check" is a Swift Testing test, not a build script: it scans `App/Opal/Presentation` for literal colours, opacities, spacing, radii, frame sizes, font sizes and animation values, so it runs with the suite. `docs/design/DESIGN-SYSTEM.md` (not `design/`) says which token to use when. The 32 snapshots (light and dark, 16 screens) match the pre-refactor build pixel for pixel. Deliberate unifications: the Link suggestion row radius 5 to 6 (`AppRadius.row`) and its detail text opacity 0.75 to 0.7 (`AppOpacity.subdued`); the Link suggestion panel is not in the snapshots. The accent is `Color.accentColor` / `controlAccentColor` and Settings has no colour picker; checking it against a changed System Settings accent is yours ([manual]).

### M6-03 Drag the split divider
As a user with two panes, I want to make one wider than the other.
Depends: M5-10
Acceptance:
- [snap] A divider between the panes can be dragged; neither pane gets narrower than 280 points, at any window size including the default 1100 points.
- [unit] The share of each pane is kept with the panes and survives switching tabs.
- [manual] Double-clicking the divider makes the panes equal again.
Status: done (29/10/2026; `EditorPanesTests`, `PresentationTokenCheckTests`, `opal-m6-03-split-default-size`, `opal-m6-03-split-share`, `opal-m6-03-split-share-min`). `HSplitView` is not used. `SplitPanesView` draws its own divider: a drag gesture (translation from the share at drag start) sets `EditorPanes.splitShare`, clamped by `EditorPanes.clampedShare` so neither pane is narrower than `EditorMetrics.paneMinWidth` (280); double-click resets to 0.5; VoiceOver can adjust it in 5% steps. The share is the first pane's fraction and lives in `EditorPanes`, so tab changes and pane focus never touch it; opening or closing a split starts even. Panes get fixed widths from a `GeometryReader`, so no pane's content width feeds back into the layout (the FIXLOG 29/10 crash). Putting a minimum width on the split container made the window renegotiate and crash with the same exception, so it is not done. At the default 1100 points with the sidebar (260) and Inspector (280) at their ideal widths the Notes column is about 558 points, a little under two panes of 280: the panes are held at 280 and the last 2 points of the second pane are clipped, and the divider cannot move until the sidebar or Inspector is narrowed or the window widened. `-OpalSplitShare <0..1>` and `-OpalHideInspector` are new launch flags. `opal-m6-03-split-default-size` is the crash case (both panes on Notes with Properties, 1100 points); `-split-share` (Inspector hidden, share 0.65) and `-split-share-min` (share 0.9, held at 280 for the second pane) show a dragged share. Dragging with the pointer and double-clicking the divider are yours to check ([manual]), as are the resize cursor and the divider's grab area; the drag itself is not covered by a snapshot or unit test.

### M6-04 Restore the split and window frames
As a user, I want Opal to come back the way I left it: each window's size and place, its panes and their tabs.
Depends: M5-12, M6-03
Acceptance:
- [unit] For each window, the saved state holds both panes' tabs, the focused pane, the split share and the window frame, outside the Vault. A Note that no longer exists is dropped from it.
- [manual] Quit with two windows, one split; relaunch shows both, in the same places, with the same panes.
Status: done (29/10/2026; `WindowStateTests`, `UserDefaultsWindowListStoreTests`, `WindowRegistryTests.restoresWindowState`, `opal-m6-04-restored-split.png`). Each window's saved state (`WindowState`, JSON under `windowState.<id>` in `UserDefaultsWindowListStore`, next to the window list) holds both panes' tabs, the focused pane, the split share and the window frame. It replaces the per-Vault `openTabs.` key, so the first launch after this build opens with no tabs. `NavigationService` saves it on every tab, pane, share and rename change; closing a window deletes its state, quitting keeps it. A Note that no longer exists is dropped from its pane at restore. The frame is stored in the state rather than with `setFrameAutosaveName`, because AppKit's autosave writes to the real `UserDefaults` domain and ignores the test suite. `WindowFrameModifier` applies it once, then saves on move and resize; a frame that is not at least 100 x 60 points on any current screen moves onto the first screen, shrunk to fit (`WindowFrame.clamped`). Runs with `-OpalVaultPath` still restore nothing; `-OpalRestoreState` turns restore back on for scripted proofs. Scripted two-launch proof on a temporary suite (`open -g`): launch 1 with a split (share 0.65) and a second window saved both states; after editing the saved frames, launch 2 reopened both windows at exactly the saved frame (-1700, 200, 1000 x 640) and clamped an off-screen frame (9000, 9000) onto the main screen, and the snapshot shows the restored split at 0.65. Quitting with Cmd-Q on real windows, and several displays, are [manual]; the Quit relaunch check is yours to do.

### M6-05 Reading view uses the Editor's font settings
As a user, I want Reading view to read in the font, size and line spacing I chose for the Editor.
Depends: M5-11
Acceptance:
- [snap] Reading view of `Tomatoes` with Serif, 18 pt and line spacing 1.4 matches the Editor's text size and spacing; code blocks stay monospaced.
- [snap] The Narrow and Readable line widths also centre Reading view.
Status: done (29/10/2026; `DesignTokenTests`, `opal-m6-05-editor.png`, `opal-m6-05-reading.png`, `opal-m6-05-reading-narrow.png`, `opal-m6-05-reading-readable.png`). NoteScreen already reads the Editor settings into one `EditorStyle`; it now also puts that value in the `editorStyle` environment, so Reading view and embeds use the same font, size, heading scale (`EditorMetrics.headingScale`), line height and line width with no second reader of the settings. Line height is `defaultLineHeight × spacing` so a wrapped paragraph has the same pitch as the Editor (53.7 against 53.5 px in the shots); code blocks keep the monospaced code font. Narrow and Readable centre the text column, as in the Editor. Same settings in both shots: Serif, 18 pt, 1.4. Shots use `-OpalHideInspector` so the pane is wider than the line width; that flag is flaky about hiding the inspector, so a shot may need a retry. Changing a setting while Reading view is open is [manual].

### M6-06 Open a recent Vault
As a user with several Vaults, I want to get back to one I used before without hunting for its folder.
Screens: `obsidian-19-vault-switcher.png`, `obsidian-01-vault-chooser.png`
Depends: M5-12
Acceptance:
- [unit] Opal keeps the last ten Vaults it opened (security-scoped bookmarks, outside the Vault); a Vault whose folder is gone is shown dimmed with "Folder not found" and can be removed from the list.
- [snap] File › Open Recent lists them by name with their folder as a subtitle, and the Welcome view lists them under its buttons.
- [unit] Choosing one follows the M5-12 rule: this window if it has no Vault, the window that already shows it, or a new window.
Status: done (29/10/2026; `RecentVaultsTests`, `opal-m6-06-welcome.png`). `VaultLocationStoring` gained `recentVaults()` and `setRecentVaults(_:)`; `UserDefaultsVaultLocationStore` keeps them as JSON (`recentVaults`, a security-scoped bookmark and the last path per Vault) in Opal's preferences, outside the Vault. `RecentVaultsService` (app-wide) resolves them, marks a Vault whose folder is gone as missing (the stored path still gives its name), keeps one entry per normalized path, newest first, at most ten (`RecentVaultsUseCase`), and offers remove and clear. `VaultService` records every Vault it opens or restores, but not one passed with `-OpalVaultPath`. Choosing one runs `VaultActions.openRecent`, which goes through `OpenVaultUseCase` like Open Vault…. Welcome lists them under its buttons (a missing one is dimmed with "Folder not found" and a Remove button; every row has Remove from List in its context menu); File › Open Recent lists name with folder as subtitle, a missing one disabled, and Clear Menu. The shot is seeded with the DEBUG flag `-OpalRecentVaults <path,path>` using only temp folders, then one folder is deleted before the second launch; the dark shot comes out with a white background, as the M6-02 Welcome one does, so only light is kept. The File › Open Recent menu (subtitles, Clear Menu, choosing from it in a second window) is [manual] and yours to check.

### M6-07 A drawn checkbox in the Editor
As a user, I want tasks in the Editor to show a checkbox I can click, as Reading view does.
Depends: M4-05
Acceptance:
- [snap] With Live Markdown on, `- [ ]` and `- [x]` draw as an empty and a ticked checkbox; the brackets show again when the cursor is on the line.
- [unit] Clicking the box changes only the character between the brackets (the M4-05 use case).
- [manual] With Live Markdown off, the text shows as written.
Status: done (29/10/2026; `CheckboxToggleUseCaseTests`, `opal-m6-07-light.png`, `opal-m6-07-dark.png`, `opal-m6-07-active-light.png`, `opal-m6-07-active-dark.png`). The styler keeps the `[ ]` in the text but makes it clear and tags it with `MarkdownCheckbox.key`; `MarkdownBlockFragment` (now also made for any line with a tagged box, quotes included) draws `square` or `checkmark.square.fill` over the three characters after the text. The brackets come back, in the old colours, when the cursor is on the line: `fadeMarks` swaps the colour and tag on selection change, so moving the cursor rewrites only the boxes whose state changed. Done tasks keep the strikethrough and faint text from M4-05. Clicking already went through the text view (`shouldChangeText`, `didChangeText`), so it is one undo step and saves like a typed edit; a click on any of the three characters toggles the one between the brackets. Between the click and the next analysis the box still shows the old state (a few milliseconds). Clicking in the running app, undo of a click, and Live Markdown off showing the text as written are [manual] and yours to check.

### M6-08 Hide the frontmatter in the Editor
As a user, I want to edit Properties in the form without the YAML showing again below it.
Depends: M4-03
Acceptance:
- [snap] When the Properties form shows, the frontmatter lines fold to one dimmed "Properties" line in the Editor; Edit as YAML unfolds them and puts the cursor there.
- [unit] Folding never changes the text: typing, undo and saving behave as if the lines were shown.
Status: done (29/10/2026; `FrontmatterFoldUseCaseTests`, `FrontmatterFoldServiceTests`, `opal-m6-08-folded-light.png`, `opal-m6-08-folded-dark.png`, `opal-m6-08-yaml-light.png`, `opal-m6-08-yaml-dark.png`). The fold is display only: the Editor's content delegate skips the frontmatter paragraphs after the first, and that first paragraph's layout fragment draws a dimmed "Properties" instead of `---`; the text storage is never touched. The fold range is scanned from the Note's text, so it never flickers while analysis catches up, and it applies with Live Markdown on or off. A caret that lands in the fold (arrow keys, Cmd-Up) moves to the start of the body (skip); a selection that covers part of the fold, a Find match inside it, an edit that starts before the body (Backspace at the top of the body) or a reveal into it unfolds it; Select All keeps it folded. Edit as YAML unfolds the Note for the session and puts the cursor on the first Property line (`-OpalEditAsYAML` does the same for snapshots). There is no control to fold again. Typing, undo and the caret in the live Editor are [manual]; a typed line saved after the fold left the frontmatter byte for byte as it was. Folded typing, undo and the caret are yours to check.

### M6-09 Property types across the Vault and `[property:value]` search
As a user, I want a Property to have one type in every Note, and to find Notes by a Property's value.
Depends: M4-03, M3-04
Acceptance:
- [unit] The Index keeps each Note's Properties; a name used with two types shows the type from `.obsidian/types.json`, or else the most common one.
- [unit] Search understands `[status:draft]`, `[status]` (has the Property) and `-[status:done]`, combined with words and `tag:`, and matches list values item by item.
- [snap] Search for `[difficulty:easy]` in `Garden` lists `Gardening Basics`.
Status: done (29/10/2026; `GRDBIndexStoreTests`, `PropertyIndexUseCaseTests`, `SearchUseCaseTests`, `SearchServiceTests`, `opal-m6-09-search.png`). The Index (schema 6, so an older Index is rebuilt from the files) keeps one `note_properties` row per Property item, with the type inferred from the value and folded copies of the name and item for matching; the store derives the rows from the Note's text, so `IndexService` is untouched. `propertyTypes(declared:)` gives one type per name: the `.obsidian/types.json` type, else the most common across Notes (ties go to the first of `PropertyType.allCases`). `[name:value]` matches Notes with a Property of that name (any case) having a value or list item that contains the text, ignoring case and accents, like `path:` and `file:`; `[name]` means has the Property; a leading `-` negates; a negated filter alone is a search. Results show the matching frontmatter line with the value marked. The Property panel still infers a type per Note: showing the Vault-wide type there is not wired yet. Typing the query in the running app is [manual] and yours to check.

## M7 — Gaps

What M6 left open, from its status notes and the M6 architecture review. UX notes are added by `improve-loop` before each story is built.

### M7-01 Split at the default window size
As a user with a default-size window, I want to drag the split divider without first closing the sidebar or the Inspector.
Depends: M6-03
Acceptance:
- [snap] At the default 1,100-point window with the sidebar and Inspector open, two panes fit at 280 points each with room to drag, and nothing is clipped.
- [unit] When the Notes column is narrower than two minimum panes, the panes still share it without clipping either one.
Status: done (29/10/2026; `EditorPanesTests`, `DesignTokenTests`, `opal-m7-01-split-default-size`). The sidebar's ideal width is now 220 points (was 260) and the Inspector's 260 (was 280), so at 1,100 points the Notes column is about 610 points: two panes of 280 plus the divider leave about 49 points to drag. The minimum stays 280. `SplitPanesView` no longer floors the width it shares at two minimum panes (that floor is what clipped the second pane): the panes always fill the column exactly, and a column under 560 points splits evenly with each pane under 280, never clipped. There is still no minimum width on the split container (FIXLOG 29/10). The snapshot shows two Notes with Properties at 1,100 points. AppKit saves the sidebar width in the app's real defaults and ignores `-OpalDefaultsSuite`, so the snapshot was taken with the saved width overridden by launch arguments; a Mac that already saved a 260-point sidebar keeps it until the user drags it. Dragging the divider with the pointer is [manual] and yours to check.

### M7-02 Fold the YAML again
As a user who chose Edit as YAML, I want to fold the frontmatter back into the "Properties" line when I am done.
Depends: M6-08
Acceptance:
- [snap] While the frontmatter is unfolded, the Properties form offers Hide YAML, and the Editor folds the lines again.
- [unit] Folding again never changes the text, and the cursor, if it was inside the frontmatter, moves to the start of the body.
Status: done (29/10/2026; `FrontmatterFoldUseCaseTests`, `FrontmatterFoldServiceTests`, `opal-m7-02-hide-yaml-light`, `opal-m7-02-hide-yaml-dark`). While a Note is unfolded in the Editor, the Properties form shows Hide YAML in the slot where Edit as YAML sits, with the help "Fold the frontmatter back into the Properties line"; in Reading view, or when the Note is folded, Edit as YAML shows instead. Hide YAML calls `NavigationService.foldFrontmatter(of:)`, which removes the Note from `unfoldedFrontmatter`; the Editor then folds the lines again as in M6-08. `FrontmatterFold.selectionAfterFolding` gives the new selection: a caret or selection that touches the frontmatter becomes a caret at the start of the body, anything in the body stays. `MarkdownTextViewCoordinator.apply` uses it when the fold goes from off to on, so a selection inside the frontmatter does not unfold it again. Nothing is written: the text is untouched. The snapshots show the unfolded Note (`-OpalEditAsYAML`) with Hide YAML. Clicking Hide YAML and seeing the lines fold and the caret move in the running app is [manual] and yours to check.

### M7-03 Vault-wide Property types in the form
As a user, I want the Properties form to show each Property with the type it has across the Vault, not one guessed from this Note alone.
Depends: M6-09
Acceptance:
- [unit] The form takes each Property's type from the Index's Vault-wide types (`.obsidian/types.json` first, else the most common type), and falls back to the Note's own value when the Index is not ready.
- [unit] When the Index changes, the open form updates its types.
- [snap] A Note whose `rating` is text, in a Vault where `rating` is a number in most Notes, shows `rating` as a number.
Status: done (29/10/2026; `PropertyServiceTests`, `opal-m7-03-vault-types-light`, `opal-m7-03-vault-types-dark`). `NoteDocument.refreshPropertyTypes()` asks the Index for `propertyTypes(declared:)` (types.json first, else the most common type) once the Index is `.ready`, and `type(of:)` uses that result; until then, or when the Index fails, it uses the types.json types and the Note's own value, as before. `PropertiesView` runs the refresh with `.task(id: index.revision)`, so the open form updates after every sync and every Note update; `IndexService` is untouched because it already publishes `revision`. A new Property added from the form takes the Vault-wide type of its name. `NoteService.type(of:)` asks the focused document. The snapshot is a temp copy of Garden with four Notes where `rating` is a number and one where it is `high`: the form shows the number icon on `rating`. Editing a value in the form and watching the type stay is [manual] and yours to check.

### M7-04 Short folder paths for recent Vaults
As a user, I want each recent Vault's folder to read the way Finder shows it, not as a long path.
Depends: M6-06
Acceptance:
- [unit] A folder in the home folder shows as `~/…`. A long path is shortened in the middle, never cut at the end.
- [snap] The Welcome view and File › Open Recent show the short form.
Status: done (29/10/2026; `FolderPathUseCaseTests`, `opal-m7-04-welcome-light`, `opal-m7-04-welcome-dark`). `FolderPathUseCase.short(_:home:limit:)` is a pure formatter: a folder in the home folder starts with `~` (a folder beside it, such as `/Users/jamie2`, does not), and a path over 40 characters keeps its first folder and as many of the last folders as fit, joined by `…`, so the Vault's parent folder is never cut at the end; two folders or fewer are never shortened. `UserHome.path` reads the real home folder from the user database (`getpwuid`), because inside the sandbox `NSHomeDirectory()` is the app's container. `RecentVault.shortParentPath` feeds the Welcome view's Recent Vaults rows and the File › Open Recent subtitles. The snapshots show Recent Vaults seeded with temp folders under the app's container, which sit under the real home, so they read `~/…/Data/tmp/m704/Work`; no real Vault name or path appears. File › Open Recent is a menu and is not in a window snapshot: opening it to see the short subtitles is [manual] and yours to check, as is a Vault in a real folder such as `~/Documents`.

## M8 — Finishing touches

What is left from Later and from M2-09. UX notes are added by `improve-loop` before each story is built.

### M8-01 Suggest Headings inside `[[`
As a user, I want to pick a Heading of a Note after typing `#`, so that I can link to it without spelling it exactly.
Screens: `obsidian-14-link-suggestions.png`, `opal-m8-01-heading-suggestions`
Depends: M2-09
Acceptance:
- [unit] `[[Note#` and a query list that Note's Headings in document order, narrowed by the M2-07 fuzzy match. The Note is the one the M2-02 resolver picks from the open Note.
- [unit] `[[#` lists the open Note's own Headings, including unsaved ones, and the inserted `[[#Heading]]` follows to that Heading.
- [unit] Choosing inserts `[[Note#Heading]]` with the shortest target, and keeps an alias already typed. With `useMarkdownLinks: true` it inserts `[Note > Heading](Note.md#Heading)`, with spaces as `%20`.
- [unit] Each inserted Link follows to the chosen Heading through `LinkFollowUseCase`, including a Heading that holds `#`, `|`, `[` or `]`, in a form Obsidian also reads.
- [unit] An Unresolved target, or a Note with no Headings, shows no list and leaves the typed text as it is.
- [snap] The list uses the `[[` panel and shows each Heading with its level. `-OpalSnapshot` also writes the open panel as `*.panel.png`, because the panel is its own window.
- [manual] ↑ ↓, Return, Tab and Esc work as in M2-09, and the insert is one undo step.
UX:
- Flow: type `[[Note#` or `[[#` -> the `[[` panel lists Headings -> typing narrows it -> ↑ ↓ choose, Return or Tab inserts and the caret lands after the Link -> ⌘Z undoes. Esc closes and the text stays. The panel is the only way in.
- Surface: the existing `[[` panel (input repeated while the person watches the result).
- States: no list for an Unresolved target, a Note with no Headings, or nothing matching, so typing is never interrupted. A long Heading cuts off with `…`.
- Words: row title is the Heading; the detail line is "Heading 2". No new terms.
- Access: the keys are as in M2-09. Level is words, not only indent or colour. The row reads as "Tomatoes, Heading 2".
Status: done (03/11/2026; `LinkSuggestionUseCaseTests`, `QuickSwitcherServiceTests.headingSuggestions`, `opal-m8-01-heading-suggestions.png`, `opal-m8-01-heading-suggestions.panel.png`). `LinkQuery.scope` says what the query asks for. Choosing a suggestion now also replaces what follows the cursor up to `]]` and keeps an alias typed there (`LinkTail`), which also stops `[[So]]` becoming `[[Soil]]]]` for Note suggestions. `linkText(forHeading:)` turns `:`, `#`, `|`, `^`, `\`, `[`, `]` and `%%` in a Heading into spaces, and following a Link compares Headings the same way, so `[[Note#C and Swift]]` finds `C# and Swift`. That this form works in Obsidian is from memory of its behaviour and was not tried in Obsidian: check [manual] in Obsidian. ↑ ↓, Return, Tab, Esc and undo are [manual] and yours to check; the snapshot run typed the text but pressed no keys.

### M8-02 Suggest Blocks inside `[[`
As a user, I want to pick a Block of a Note after typing `#^`, so that I can link to one paragraph or list item.
Screens: `obsidian-14-link-suggestions.png`, `opal-m8-02-block-suggestions`
Depends: M8-01
Acceptance:
- [unit] `[[Note#^` and a query list the Blocks in that Note that already have a `^id`, matching on the id and the Block's text. `[[#^` does the same for the open Note.
- [unit] Choosing inserts `[[Note#^id]]`, and the Link follows to that Block through `LinkFollowUseCase`. With `useMarkdownLinks: true` it inserts `[Note > ^id](Note.md#^id)`.
- [unit] A paragraph with no `^id` is not listed, and no Note other than the open one changes.
- [snap] Each row shows the Block's text, cut to one line, and its id.
UX:
- Flow: type `[[Note#^` or `[[#^` -> the panel lists Blocks -> typing narrows by text or id -> Return or Tab inserts -> ⌘Z undoes. Esc closes.
- Surface: the existing `[[` panel.
- States: no list when the Note has no Blocks with an id. A Block made of only `^id` on its own line shows the line above it. Long text cuts off with `…`.
- Words: row title is the Block's text, detail is `^id`. No new terms.
- Access: as in M8-01.
Status: done (03/11/2026; `LinkSuggestionUseCaseTests`, `opal-m8-02-block-suggestions.png`, `opal-m8-02-block-suggestions.panel.png`). The parser now keeps each Block's text (a line holding only `^id` takes the line above, list markers are dropped), so the panel reads no file while typing. That changes the stored parse, so the Index is schema 7 and an older Index rebuilds from the files on next open. Keys and undo are [manual] and yours to check, as is the Markdown form `[Note > ^id](Note.md#^id)` in Obsidian.

### M8-03 Change a command's shortcut
As a keyboard user, I want to give any command the shortcut I choose.
Screens: `obsidian-24-settings-hotkeys.png`, `opal-m8-03-settings-shortcuts`
Depends: M5-08, M5-11
Acceptance:
- [snap] A Shortcuts tab in Settings lists every `AppCommand` and the Command Palette by group, each with its current shortcut, and a field filters the list by name.
- [unit] A shortcut needs ⌘ or ⌃, or is a function key. It is stored by command id in `OpalSettings`, so Opal's preferences hold it and the Vault does not. A command with no saved value uses its default.
- [unit] A saved id that no longer names a command is ignored and does not stop the others from loading.
- [unit] The shortcut text in the palette comes from the same value as the menus.
- [manual] Click a row, press keys and the new shortcut works at once in the menus and the palette, in every window. Esc cancels.
- Folder tree row actions, such as ⌘⌫, and standard system menu items stay as they are. System Settings › Keyboard can already change menu shortcuts.
UX:
- Flow: Opal › Settings… (⌘,) › Shortcuts -> type in Filter to narrow the list -> click a command's shortcut -> it reads "Type Shortcut…" -> press keys and it saves at once, or Esc cancels. No Save button.
- Surface: a Settings tab (a place people come back to), grouped rows like the other tabs. Recording is inline in the row, because it changes one value on screen.
- States: a command with no shortcut shows "Add Shortcut". Filter with no match: "No Commands" with the filter text. While recording, keys go to the row and not to menus. A key with no ⌘ or ⌃ stays in recording and shows "Include ⌘ or ⌃".
- Words: tab "Shortcuts", field "Filter", "Type Shortcut…", "Add Shortcut". Help on the row: "Change the shortcut for New Note". New term: Shortcut (Glossary).
- Access: every row is a button with the command's name and shortcut as its label. Space or Return starts recording; Tab moves on when not recording.
Status: done (03/11/2026; `ShortcutUseCaseTests`, `opal-m8-03-settings-shortcuts.png`, `opal-m8-03-palette-saved-shortcuts.sheet.png`). The rules are pure (`ShortcutUseCase`) over plain values, the choices are `OpalSettings.shortcuts` keyed by command id, and `AppCommand` keeps only the defaults. The Command Palette is now an `AppCommand` that the palette does not list. The palette shot ran with test settings that gave New Note ⌥⌘K and took Save's shortcut away, and showed both. A local key monitor catches keys while recording, before the menus see them. `-OpalShortcutState recording` starts on New Note for the shot. Clicking a row, pressing keys, Esc, and the new shortcut running from the menus in every window are [manual] and yours to check: a snapshot run presses no keys.

### M8-04 Resolve a shortcut conflict
As a keyboard user, I want to be told when a shortcut is already in use, so that I do not lose a command by accident.
Screens: `opal-m8-04-shortcut-conflict`
Depends: M8-03
Acceptance:
- [unit] A shortcut held by another command is reported with that command's name, including a default the user never changed. Nothing is saved until the user chooses.
- [snap] The row names the other command and offers Replace and Cancel. Replace gives the other command no shortcut.
- [unit] Shortcuts macOS and Opal's editing rely on (⌘Q, ⌘H, ⌘M, ⌘C, ⌘V, ⌘X, ⌘Z, ⇧⌘Z, ⌘A, ⌘F, ⌘G) are refused with a reason.
UX:
- Flow: press a shortcut in use -> the row says "Used by New Tab" and shows Replace and Cancel -> Replace moves it, and New Tab has none; Cancel or Esc keeps both as they were.
- Surface: inline in the row (one value on screen); not an alert, because nothing is lost.
- States: a reserved shortcut stays in recording and shows "⌘Q is used by macOS" or "⌘C is used for editing".
- Words: "Used by New Tab", "Replace", "Cancel".
- Access: focus moves to Replace. VoiceOver reads the message.
Status: done (03/11/2026; `ShortcutUseCaseTests`, `opal-m8-04-shortcut-conflict.png`, `opal-m8-04-shortcut-reserved.png`). While a conflict is showing, the row shows the keys pressed, Return replaces and Esc cancels. Pressing keys, Replace and Cancel in the running app are [manual] and yours to check; `-OpalShortcutState conflict` and `reserved` draw the two rows for the shots.

### M8-05 Remove or restore a shortcut
As a keyboard user, I want to clear a shortcut, or go back to Opal's defaults.
Screens: `opal-m8-05-shortcut-restore`
Depends: M8-03
Acceptance:
- [unit] Removing leaves the command with no shortcut, and that survives a relaunch, so "no shortcut" is stored apart from "default".
- [unit] Restoring one row returns its default. If another command now holds that shortcut, M8-04's conflict applies.
- [snap] A changed row shows Restore Default, and the tab has Restore All Defaults.
- [manual] Restore All Defaults asks first, then applies at once.
UX:
- Flow: a changed row shows Restore Default in its context menu and as a small button -> one click restores. A row with a shortcut has Remove Shortcut in the context menu. Restore All Defaults at the foot of the tab -> a confirmation -> all return.
- Surface: inline for one row; a confirmation dialog for all, because it throws away many choices at once.
- States: Restore All Defaults is disabled when nothing has changed. Restoring into a conflict uses M8-04's row.
- Words: "Remove Shortcut", "Restore Default", "Restore All Defaults…", "Restore All Shortcuts?" with "Every command goes back to Opal's shortcut.", buttons "Restore All" and "Cancel".
- Access: the context menu actions are also reachable by VoiceOver actions on the row.
Status: done (03/11/2026; `ShortcutUseCaseTests`, `opal-m8-05-shortcut-restore.png`). `ShortcutChoice.removed` is what makes "no shortcut" different from "default"; removing a shortcut from a command with no default just clears the saved one. Restore All Defaults sits under the list, so it stays visible while the list scrolls. The context menu, the restore button, and the confirmation are [manual] and yours to check: a snapshot cannot open a menu or press a button.

### M8-06 Choose any installed font
As a writer, I want to write in any font on my Mac, not only the four system designs.
Screens: `obsidian-23-settings-appearance.png`, `opal-m8-06-font-editor`, `opal-m8-06-font-reading`
Depends: M5-11, M6-05
Acceptance:
- [snap] Settings › Editor › Font lists System, Serif, Rounded and Monospaced, then a divider, then every installed family by name. The snapshots use a font every Mac has, such as Georgia.
- [snap] The Editor and Reading view both use the chosen family at the same size and line spacing. Code stays in the monospaced code font.
- [unit] A saved design keeps working after the update, with no change to what the user chose.
- [unit] A family that is no longer installed draws in System, and the setting stays, so the font returns when it is installed again.
- [snap] A missing family shows as "Georgia (not installed)" in the Font row.
- [manual] Bold, italic and Heading weights look right, or fall back cleanly, in a family with one weight. Changing the font applies at once, and typing in a large Note stays smooth.
UX:
- Flow: Settings › Editor › Font -> choose a family -> the open Editor and Reading view change at once. The Editor rebuilds, as for every Editor setting.
- Surface: the existing Font picker (one value on screen), a standard menu that scrolls, with the four designs first.
- States: an uninstalled family stays selected, as "Georgia (not installed)". The text draws in System until it comes back.
- Words: Font, System, Serif, Rounded, Monospaced, then family names as macOS gives them. "(not installed)".
- Access: a standard picker; VoiceOver reads label and value.
Status: done (03/11/2026; `EditorFontFamilyUseCaseTests`, `opal-m8-06-font-editor.png`, `opal-m8-06-font-reading.png`, `opal-m8-06-font-settings.png`, `opal-m8-06-font-missing.png`, `opal-m8-06-font-missing-editor.png`). The family is a new key beside the design, so a saved design is untouched and an empty family means "use the design". Choosing a design clears the family. The list of families is read once per launch, so a font installed while Opal runs appears after a relaunch. The snapshots show Georgia's bold and Heading weights, and System when the family is missing; code stays monospaced. A one-weight family, changing the font live and typing in a large Note are [manual] and yours to check; the font is looked up as styling runs, and I did not measure typing with it.

### M8-07 Choose whether Opal reopens Vaults at launch
As a user, I want Opal to start on the Welcome window if I prefer to choose a Vault each time.
Screens: `obsidian-20-settings-general.png`, `opal-m8-07-settings-general`, `opal-m8-07-welcome`
Depends: M5-11, M6-04, M6-06
Acceptance:
- [snap] A General tab comes first in Settings, with one toggle: "Reopen Vaults at launch", with the help "Open the windows and Vaults you had open when you last quit".
- [unit] The setting lives in `OpalSettings` and is on when the key is missing, so nothing changes for anyone who has not chosen.
- [unit] When it is off, launch opens one Welcome window with Recent Vaults and restores no Vault or window. Saved window states are kept, so turning it on again restores them at the next launch.
- [unit] `-OpalVaultPath` still opens its folder, whichever way the setting is.
- [manual] Quit with two windows with it off, relaunch, choose a recent Vault, and it opens as usual.
UX:
- Flow: Settings › General -> toggle "Reopen Vaults at launch" -> the next launch follows it. No confirmation; nothing happens to open windows now.
- Surface: a Settings tab, first in the row, as on every Mac. One toggle.
- States: on by default. When off, launch shows Welcome with Recent Vaults.
- Words: tab "General"; "Reopen Vaults at launch"; description "Opens the windows and Vaults you had open when you last quit."
- Access: a standard toggle, its description read with it.
Status: done (03/11/2026; `WindowRegistryTests`, `opal-m8-07-settings-general.png`, `opal-m8-07-welcome.png`). The setting is read once at launch. When it is off, `WindowRegistry` restores nothing, does not write the saved window list, and on quit deletes the state of that session's windows, so the windows of the last session with it on stay safe. The first window also stops falling back to the last Vault. So turning it on restores the last session that ran with it on, not one that ran with it off: a Vault opened during an off session does not come back. Scripted proof on a temporary suite: a launch with the setting off opened Welcome with the saved list untouched; that run used a list with no Vault bookmark, because a snapshot run cannot create one. Quitting with two windows and a real Vault, then relaunching, is [manual] and yours to check.

## M9 — Redesign

The new look from `docs/design/redesign/opal-redesign.html` (Claude Design, 03/11/2026): a frosted window, floating panels, an opal-rose accent, Folder and Tag colours, and a Vault home of cards. Decisions are in ADR 0009. The tokens are in `Modules/OpalKit/Sources/OpalDesign` (`AppBrandColor`, `AppLabelColor`, new `AppSpacing` and `AppRadius` steps). Every story is checked in light and dark, and every `[snap]` has a `-dark` twin. The reference shows the Garden fixture, so its snapshots compare directly. UX notes are added in `improve-loop`, just before each story is built.

### M9-01 Choose the accent colour
As a user, I want Opal in its own opal-rose, or in my macOS accent if I prefer.
Screens: redesign `8 · Settings` (Appearance), `opal-m9-01-settings-appearance`, `opal-m9-01-accent-system`
Depends: M5-11
Acceptance:
- [snap] Settings › Appearance has "Accent" with two choices, Opal and System, below the light/dark choice.
- [unit] The setting lives in Opal's preferences, outside the Vault, and is Opal when the key is missing.
- [unit] `AppColor.accent`, `AppKitColor.accent` and `AppColor.onAccent` follow the setting; every accent role (links, selection, Tag pill, search match, toggles) changes with it. No view reads `AppBrandColor` directly.
- [snap] With System, a snapshot shows the macOS accent everywhere the rose was.
- [manual] Changing it while Opal runs changes every open window without a relaunch.
Status: done (03/11/2026; `AppAccentTests`, `opal-m9-01-settings-appearance-light.png`, `-dark`, `opal-m9-01-accent-opal-light.sheet.png`, `opal-m9-01-accent-system-light.sheet.png`). `AppAccent` (OpalDesign) holds the choice; `AppKitColor.accent` and `.onAccent` are dynamic colours that read it as they draw, so every role built on them follows. `AppDependencies` sets it at launch from the preferences suite, and `followsAccent()` on every window and Settings keeps it in step and tints SwiftUI controls. The accent is part of `EditorStyle`, so changing it rebuilds the Editor, which sends the caret back to the start, as other Editor settings do. Changing it live is [manual] and yours to check; on this Mac the System accent is pink, so the System snapshot is pink, not rose.

### M9-02 Frosted window with floating panels
As a user, I want a calm, light window where the Note sits on paper and the sidebar and Inspector float beside it.
Screens: redesign `2 · Vault home`, `3 · Note in the Editor`, `opal-m9-02-window`
Depends: M9-01
Acceptance:
- [snap] The window uses `material.window` over `color.window` with radius `AppRadius.window`; the sidebar and Inspector are panels at `AppRadius.sidebar` with `AppSpacing.small` inset; the Editor sits on `color.paper`.
- [snap] The standard traffic lights, toolbar and sidebar toggle stay; no custom title bar.
- [unit] `PresentationTokenCheckTests` still passes: no raw colour, radius or spacing in a view.
- [manual] With Reduce Transparency on, the window and panels turn opaque and text keeps 4.5:1 contrast.
- [manual] Resizing and hiding the sidebar or Inspector stays smooth in a 10,000-Note Vault.
Status: done (03/11/2026; `opal-m9-02-window-light.png`, `-dark`). The window draws `AppColor.window` over `.thinMaterial` as its container background, and the Editor area is paper (`AppColor.editorBackground`, now translucent) clipped to `AppRadius.sidebar` with `AppSpacing.small` inset. The sidebar and Inspector stay the native macOS 26 split view and inspector, which already float as glass, so no custom chrome. Both translucent colours turn opaque with Reduce Transparency. A checked box now draws its tick in `onAccent`. `-OpalSnapshot` uses `cacheDisplay`, which does not draw materials, so the snapshots show the layout and the paper card, not the frost: the frost, Reduce Transparency and smooth resizing are [manual] and yours to check.

### M9-03 See the Vault, its Folders and Recent Notes in the sidebar
As a user, I want the sidebar to show the Vault's name and size, coloured Folders, and the Notes I opened last.
Screens: redesign `2 · Vault home` (sidebar), `opal-m9-03-sidebar`
Depends: M9-02
Acceptance:
- [snap] The sidebar header shows the Vault name and "42 Notes", with the Cards/List switch beside it on Vault home.
- [snap] Each Folder icon uses its Folder colour (M9-06); a Folder with no colour uses `AppLabelColor.neutral`.
- [snap] A "Recent Notes" section lists up to 5 Notes opened last, with "2 min", "1 h", "Yesterday".
- [unit] Recent Notes come from navigation history kept in Opal's preferences, per Vault, never from the Index alone.
- [unit] A Note deleted or renamed outside Opal drops out or follows its new name.
Status: done (03/11/2026; `RelativeAgeUseCaseTests`, `opal-m9-03-sidebar-light.real.png`, `-dark.real.png`). The header shows the Vault name and its Note count. Folder icons use `AppLabelColor.neutral` until M9-06 adds Folder colours. Recent Notes reuses `NavigationService.recentNotes`, which M2-07 already keeps per Vault in Opal's preferences and which already follows a rename or move made in Opal; the section lists the first five that still exist, so a Note deleted or renamed outside Opal drops out. The age is the file's modification date from disk, not when it was opened, so it matches the cards on Vault home. The Cards/List switch moves to M9-05, where it has something to switch. These snapshots are real window captures (`screencapture -l`), so they show the glass.

### M9-04 Star a Note
As a user, I want to star the Notes I come back to, so they sit at the top of the sidebar.
Screens: redesign `2 · Vault home` (Starred), `opal-m9-04-starred`
Depends: M9-03
Acceptance:
- [snap] A "Starred" section sits above the Folder tree. It is hidden when nothing is starred.
- [self] Star and Unstar are in the Note's context menu, the Command Palette and the Note menu.
- [unit] Stars are stored per Vault in Opal's own preferences, by Vault-relative path. Opal writes nothing to the Vault or `.obsidian/`.
- [unit] Renaming or moving a starred Note in Opal keeps the star; a starred Note deleted outside Opal is dropped from the list.
Status: done (03/11/2026; `StarredNotesTests`, `opal-m9-04-starred-light.real.png`, `-dark.real.png`). Stars live in `NavigationService.starredNotes`, saved through `StarredNotesStoring` (`UserDefaultsStarredNotesStore`, key `starredNotes.<Vault path>`) in Opal's preferences, so nothing is written to the Vault. Star and Unstar are in a Note's context menu in the Folder tree and on a Starred row; File › Star Note / Unstar Note and the Command Palette's "Star or Unstar Note" act on the open Note. Opal has no Note menu, so the command sits in File beside Duplicate Note. `forget` and `move` already run for Trash, rename and move in Opal, and now carry the star with them; a starred Note deleted outside Opal is hidden from the section because it is no longer a Note in the Vault. The context menus are [manual] and yours to check.

### M9-05 Open Vault home
As a user, I want a home page of cards when no Note is open, so I can see what I worked on and jump back in.
Screens: redesign `2 · Vault home`, `opal-m9-05-vault-home-cards`, `opal-m9-05-vault-home-list`
Depends: M9-03, M9-06
Acceptance:
- [snap] With no Note open, the Editor area shows a search field ("Search Notes", ⇧⌘F), then "Recently edited" with the 6 last edited Notes as cards, then one group per top Folder.
- [snap] Each card shows the Note's name, up to 4 lines of preview (Markdown hidden, task lists as lines), "2 minutes ago", and its first Tag or Folder. Its 3 pt top edge uses the Folder colour.
- [snap] The Cards/List switch shows the same Notes as a list; the choice is remembered per window.
- [self] Click or Return on a card opens the Note; ⌘-click opens it in a new tab; the cards take arrow-key focus.
- [unit] Previews and dates come from the Index, and the page builds in under 100 ms for a 10,000-Note Vault (measured with `OSSignposter`).
Status: done (03/11/2026; `NotePreviewUseCaseTests`, `VaultHomeUseCaseTests`, `VaultHomeServiceTests`, `LargeVaultPerformanceTests`, `opal-m9-05-vault-home-cards-light.real.png`, `-dark.real.png`). With no Note open in a single pane, the Editor area shows `VaultHomeView`. `VaultHomeService` reads file dates from the Index (`stamps()`) and the text of only the shown Notes (new `IndexStoring.texts(of:)`), and takes the first Tag from the Link map, all inside an `OSSignposter` interval "Vault home". `VaultHomeUseCase` picks the 6 newest Notes and up to 8 top Folders, newest first, 3 Notes each; `NotePreviewUseCase` hides frontmatter, a title Heading, Markdown marks, Block ids, empty tasks, table rows and code fences. A card's top edge and the group dot use the Folder colour (M9-06), grey without one. Return or a click opens a card, ⌘ opens it in a new tab, and arrow keys move focus card by card in reading order. The search field runs Search with its text. 10,000 Notes build the home in under 100 ms in release (`OPAL_PERF=1`); the first-index budget in the same test fails on `main` too (42 s against 20 s), so that failure is older than M9. The List layout, ⌘-click and arrow keys are [manual] and yours to check; `@SceneStorage` cannot be seeded from a snapshot run.

### M9-06 Choose a Folder's colour
As a user, I want to colour a Folder, so its Notes are easy to spot on cards and in the sidebar.
Screens: redesign `Colour — Folders and Tags`, `opal-m9-06-folder-colour`
Depends: M9-02
Acceptance:
- [self] The Folder's context menu has "Colour" with the seven `AppLabelColor` swatches and None.
- [unit] Colours are stored per Vault in Opal's preferences, by Folder path, and follow a rename or move made in Opal.
- [unit] With no choice, Folders get no colour: the defaults in the reference (Projects blue, Areas teal…) are only what the snapshot seeds.
- [snap] The colour shows on the Folder icon, the card top edge and the dot, and nowhere else.
Status: done (03/11/2026; `FolderColourUseCaseTests`, `FolderColourServiceTests`, `opal-m9-06-folder-colour-light.real.png`, `-dark.real.png`). `FolderColour` (OpalCore) has seven swatches: Blue, Teal, Purple, Amber, Green, Slate, Grey. `AppLabelColor` now names them by colour, not by the reference's default Folders. `FolderColourService` keeps them per Vault through `FolderColourStoring` (`folderColours.<Vault path>` in Opal's preferences). A Note or sub-Folder takes the colour of its nearest coloured Folder. `RenameService` carries colours through a rename or move and drops them on Trash, including colours set inside the Folder. The Folder's context menu has a Colour picker with None and the swatches. The snapshot seeds the reference's colours through the preferences suite. The card edge and dot arrive with M9-05; the context menu is [manual] and yours to check.

### M9-07 See where the Note is and how big it is
As a user, I want the Note's Folder and last edit above the text, and its size below it.
Screens: redesign `3 · Note in the Editor`, `opal-m9-07-note-header`
Depends: M9-02
Acceptance:
- [snap] The toolbar shows the Note's name, then "Garden · Edited just now", and an Editing/Reading switch.
- [snap] A quiet line at the foot of the Editor shows "186 words · 4 Links · 3 Backlinks" and "Created 14 Mar 2026 · Edited just now".
- [unit] Word and Link counts come from the open text, so they update as the user types, without a file read.
- [unit] Created comes from the `created` Property when present, else the file's creation date.
Status: done (03/11/2026; `NoteStatsUseCaseTests`, `opal-m9-07-note-header-light.real.png`, `-dark.real.png`). The window subtitle adds "· Edited …" from the file's date on disk, refreshed when the Note saves. The Reading view button is now an Editing/Reading segmented switch, still ⌘E. `NoteStatusBar` sits at the foot of the Editor and Reading view: words in the body (frontmatter left out; a Link counts its target's and alias's words), Links in the Note and Backlinks to it from the Link map, then Created and Edited. Created comes from a `created` Property (`yyyy-mm-dd`), else the file's creation date through the new `VaultFileStoring.created(of:)`. Counts come from the text in memory, so they follow typing with no file read; the dates are read once per save.

### M9-08 Restyle the Properties block
As a user, I want Properties as a calm block above the text, with each Tag as a pill.
Screens: redesign `3 · Note in the Editor`, `opal-m9-08-properties`
Depends: M9-02
Acceptance:
- [snap] Properties sit in a `color.fill` block at `AppRadius.card`, each row with its icon, name and value; Tags and aliases show as pills; "Add Property" and "Edit as YAML" stay.
- [unit] The YAML on disk is byte-for-byte the same after opening and closing the Note (M1-06 still holds).
Status: done (03/11/2026; `opal-m9-08-properties-light.real.png`, `-dark.real.png`). The Properties form sits in a `AppColor.fill` block at `AppRadius.card`, inset to the text. Edit as YAML and Hide YAML are in the accent. Tags show as accent pills, aliases and other lists as neutral pills (`AppColor.fill2`); clicking the pills turns them into the comma-separated field, and leaving it saves as before. Only the view changed: the file is written only through the existing `setProperty`, so M1-06's byte-for-byte tests still pass. Click-to-edit is [manual] and yours to check.

### M9-09 Restyle the Editor and Reading view type
As a user, I want the text set like a good book: a clear title, calm headings, roomy lines.
Screens: redesign `3 · Note in the Editor`, `4 · Reading view`, `opal-m9-09-editor-type`, `opal-m9-09-reading-type`
Depends: M9-02
Acceptance:
- [snap] The Editor uses `note.title 30/34`, `note.h2 20/26`, `note.body 16/26`; Reading view uses `reading.title 36/40`, `reading.h2 22/28`, `reading.body 17/29`, with `AppSpacing.editorMargin` sides.
- [snap] Links use the accent; an Unresolved Link is fainter; a Heading Link reads "Soil › compost rule".
- [unit] The type sizes are `EditorMetrics` values and follow the Editor font and size settings (M5-11, M8-06) by ratio.
Status: done (03/11/2026; `DesignTokenTests.typeScale`, `opal-m9-09-editor-type-light.real.png`, `-dark`, `opal-m9-09-reading-type-light.real.png`, `-dark`). The default Editor size is now 16 pt, and every size is a ratio of the Editor size setting, so 16 gives the redesign's 30/20/16 in the Editor and 36/22/17 in Reading view, line height 29 for Reading body. Heading 1 is bold and the rest semibold. The text inset is 48 (`EditorMetrics.textInset`), shared by the Editor, the Properties block and Reading view. A Heading or Block Link in Reading view now reads "Soil › Watering". A Block keeps its `^id`, because the id is the user's text. The Markdown Link Opal writes still uses Obsidian's `>`. Anyone who saved a size keeps it; only the default moved from 15 to 16.

### M9-10 Read Backlinks as cards
As a user, I want each linking Note as a small card with its lines in context, so I see at a glance who links here.
Screens: redesign `5 · Inspector with Backlinks`, `opal-m9-10-backlinks`
Depends: M9-02
Acceptance:
- [snap] The Inspector tabs are a pill switch: Backlinks, Outgoing, Outline, Tags.
- [snap] Backlinks shows "Linked · 5 Notes · 8 Links", then one card per Note (`AppRadius.inner`) with its Folder, Link count and each line, the Link marked with `color.mark`.
- [snap] Embeds show as "Embeds the block Soil › compost rule"; Unlinked mentions follow with their count and Link button (M3-05).
- [self] Clicking a line opens the Note at that line.
Status: done (03/11/2026; `BacklinkGroupUseCaseTests`, `opal-m9-10-backlinks-light.real.png`, `-dark.real.png`). Backlinks shows "Linked" with "6 Notes · 9 Links", then one `BacklinkCard` per Note with its Folder and Link count. Each line shows its text with Markdown hidden and the Link that points here, shown by alias or as "Note › Heading", marked in `AppColor.mark` (`BacklinkGroupUseCase.markedContexts`). When one line has several Links to the Note, each Backlink marks its own. Unlinked mentions follow below with their count and Link button. The Inspector tabs were already a segmented pill. An Embed reads by its target ("Soil › ^compost-rule"), not "Embeds the block": the Link map does not tell a Block Embed from a Heading Embed here, so that wording is left for later.

### M9-11 Filter Search results
As a user, I want to narrow Search by Folder, Tag and where the match is, without typing operators.
Screens: redesign `6 · Search results`, `opal-m9-11-search`
Depends: M9-05
Acceptance:
- [snap] Search fills the Editor area: the field, then pop-up buttons "All Folders", "Any Tag", "Text and Properties", and a "Match Case" toggle.
- [snap] A summary reads "12 matches in 6 Notes · Sorted by relevance". Results group by Note with Folder and count; each match line says Text, Quote or Property.
- [unit] Each pop-up writes the same `path:`, `tag:` and Property filters as M3-02, so typed and chosen filters give the same results.
Status: done, with three parts moved to Later (03/11/2026; `SearchFilterUseCaseTests`, `opal-m9-11-search-light.real.png`, `-dark.real.png`). Under the Search field, "All Folders" and "Any Tag" pop-ups list the top Folders and Tags. Choosing one writes `path:"…"` or `tag:#…` into the query through `SearchFilterUseCase`, replacing an earlier one, so typed and chosen filters give the same `SearchQuery`. A summary reads "19 matches in 8 Notes", and each line says Text, Quote or Property (`SearchLineKind`, set in `SearchSnippetUseCase` from the frontmatter and a leading `>`). Search stays in the sidebar rather than filling the Editor area, because Vault home already puts a search field there. "Match Case" and the "Text and Properties" scope are not built: the full-text Index folds case, so they need their own query work. All three are in Later. Sorting by relevance is what Search already did.

### M9-12 Preview a Note in the Quick Switcher
As a user, I want to see the start of a Note before I open it from the Quick Switcher.
Screens: redesign `7a · Quick Switcher`, `opal-m9-12-quick-switcher.sheet`
Depends: M9-02
Acceptance:
- [snap] The switcher floats at `AppRadius.popover` on `material.popover`, with results on the left and a preview of the selected Note on the right (title and first Headings with their text).
- [snap] Each row shows the name with the matched letters marked, its Folder and aliases ("Garden · also Dirt, Earth").
- [snap] A foot bar shows ↑↓ Move, ↩ Open, ⌘↩ Open in New Tab, esc Close.
- [unit] The preview reads from the Index and the cache; moving the selection never blocks typing.
Status: done (03/11/2026; `FuzzyHighlightUseCaseTests`, `opal-m9-12-quick-switcher-light.real.png`, `-dark.real.png`). The switcher is wider (760 × 420), with results on the left and `SwitcherPreview` on the right: the selected Note's name and its first lines, read from the Index text through `VaultHomeService.preview(of:lines:)` in a task keyed on the selection, so moving never waits on it. Rows mark the typed letters (`FuzzyHighlightUseCase`: a run if the letters sit together, else in order) and show the Folder, or the Vault for a root Note, plus "also" and its aliases. `KeyHintBar` (shared, for M9-13) shows ↑↓ Move, ↩ Open, ⌘↩ Open in New Tab, esc Close. The panel is still a system sheet, so its radius and material are the system's; the preview keeps lines, not Headings in bold. The snapshot captures the window's screen area (`screencapture -R`) so the sheet is in it.

### M9-13 Restyle the Command Palette
As a user, I want the Command Palette in the same floating style as the Quick Switcher.
Screens: redesign `7b · Command Palette`, `opal-m9-13-palette.sheet`
Depends: M9-12
Acceptance:
- [snap] Same panel, radius and foot bar as M9-12; each row shows group, name and shortcut, the selected row in `color.accentSoft`.
- [unit] Shortcuts shown are the user's own (M8-03).
Status: done (03/11/2026; `opal-m9-13-palette-light.real.png`, `-dark.real.png`). The Command Palette uses the same `KeyHintBar` as the Quick Switcher (↑↓ Move, ↩ Run, esc Close), is 600 wide, and marks the selected row with `AppColor.accentSoft` and accent text instead of a solid fill. Shortcuts sit in small key chips and are the user's own (M8-03, unchanged code path). As with M9-12 the panel is a system sheet.

### M9-14 Restyle Settings
As a user, I want Settings to match the new look while staying a standard Mac Settings window.
Screens: redesign `8 · Settings — all 6 tabs`, `opal-m9-14-settings-<tab>`
Depends: M9-01
Acceptance:
- [snap] All six tabs (General, Editor, Files & Links, Daily Notes, Appearance, Shortcuts) use grouped rows at `AppRadius.card`, the accent for toggles, and "Set by this Vault's Obsidian settings" as a quiet caption.
- [unit] No setting moves or changes meaning; every existing Settings test passes.
Status: done (03/11/2026; `opal-m9-14-settings-<tab>-light.real.png`, `-dark.real.png` for all six tabs). Settings already used grouped `Form` rows, which on macOS 26 are the redesign's rounded groups, and "Set by this Vault's Obsidian settings" was already a quiet caption, so the window stays native. `followsAccent()` (M9-01) tints its toggles and pickers. Live Markdown gains the reference's description, "Hides Markdown syntax, except on the line you are editing." No setting moved or changed meaning. The snapshots show the window inactive, so controls are grey; the accent on a key window is [manual].

### M9-15 Restyle Welcome
As a user, I want the first window to feel like the rest of Opal.
Screens: redesign `1 · Welcome`, `opal-m9-15-welcome`
Depends: M9-02
Acceptance:
- [snap] "Welcome to Opal", the one-line explanation, Open Vault… (primary) and Create Vault…, then Recent Vaults as rows with short paths (M7-04), in a frosted window.
- [unit] Nothing in Welcome writes to a Vault.
Status: done (03/11/2026; `opal-m9-15-welcome-light.real.png`, `-dark.real.png`). Welcome sits in the frosted window (M9-02) with Open Vault… as the default button and Create Vault…. Recent Vaults now sit in a rounded `AppColor.fill` group with short paths (M7-04). "An Obsidian Vault works as it is" uses the glossary's capital V, here and in the Open panel. Welcome writes nothing to a Vault: no code in it changed beyond layout and words. The Open Vault… accent fill shows only in a key window, so the snapshot shows it grey.

## M10 — After the redesign

What M9 left open, from its status notes, the M9 architecture review and Later. Decided without the user, who asked for the work to go on unattended (03/11/2026); each choice is in the story's Status. Search in the Editor area and Obsidian's bookmarks stay in Later.

### M10-01 Match Case and a Text / Properties scope in Search
As a user, I want to find only exact-case matches, and to search only a Note's text or only its Properties.
Screens: `opal-m10-01-search`
Depends: M9-11
Acceptance:
- [snap] Under the Search field, beside "All Folders" and "Any Tag", a "Text and Properties" pop-up (Text and Properties, Text only, Properties only) and a "Match Case" toggle.
- [unit] Match Case keeps only Notes and lines whose text holds the words in the same case. The Index still folds case; the filter runs on the matched lines.
- [unit] Text only drops Property lines; Properties only keeps only Property lines. A Note with no line left is not shown.
- [unit] The summary counts what is shown after the filters.
Status: todo

### M10-02 Backlinks say when a Note embeds this one
As a user, I want to see at a glance that a Backlink is an Embed, not a plain Link.
Screens: `opal-m10-02-backlinks`
Depends: M9-10
Acceptance:
- [unit] A line whose Link is an Embed (`![[…]]`) reads "Embeds Soil", "Embeds Soil › Compost" or "Embeds the block Soil › ^compost-rule" in Backlinks.
- [snap] The marked part in the card is the same as for a Link.
Status: todo

### M10-03 Index 10,000 Notes inside the budget
As a user with a large Vault, I want the first Index to finish fast.
Screens: none
Depends: M3-01
Acceptance:
- [unit] `LargeVaultPerformanceTests` "first index" of 10,000 Notes finishes under its 20 s budget in Debug.
- [unit] The Index holds the same Notes, Links, Tags and text as before.
Status: todo

### M10-04 Add a Block id from `[[#^`
As a user, I want to link to any paragraph, not only to ones that already have a `^id`.
Screens: `opal-m10-04-block-id.panel`
Depends: M8-02
Acceptance:
- [snap] `[[Soil#^` lists the target's paragraphs without an id after the ones with one, each marked "Add id".
- [unit] Choosing one inserts `[[Soil#^<new id>]]` and adds ` ^<new id>` at the end of that paragraph in the target Note. The id is six lowercase letters and digits, unique in the Note.
- [unit] Opal writes the target only after the user confirms; Cancel changes neither Note. The confirm says which Note changes.
- [unit] The rest of the target Note is unchanged, byte for byte.
Status: todo

## Later

- Search in the Editor area (M9-11 kept Search in the sidebar; Match Case and the scope are M10-01).
- Read and write Obsidian's bookmarks (`.obsidian/bookmarks.json`) as Starred. Opal never writes inside `.obsidian/`, so M9-04 keeps stars in Opal's preferences.

## Dropped

- Graph view (`obsidian-17-graph-view-out-of-scope.png`), Canvas, plugins, sync, publishing and collaboration: out of scope for v1 (design brief).
- iOS and iPadOS: out of scope for v1.
- Account and update settings (`obsidian-20-settings-general.png`): Opal has no account or update channel.
- Reading shortcuts from `.obsidian/hotkeys.json`: Obsidian's command list is not Opal's, and M8-03 keeps shortcuts in Opal's own Settings.
