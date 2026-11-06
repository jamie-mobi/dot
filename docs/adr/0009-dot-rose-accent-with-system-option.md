# 0009 — Redesign: Dot-rose accent, frosted window, larger radii

Date: 03/11/2026. Status: accepted (the user chose the accent option and approved the frosted window and larger radii on 03/11/2026).

## Context

The redesign in `Dot Redesign.html` gives Dot an dot-rose accent (`#B8336F` light, `#F07AAE` dark), a frosted window and radii up to 26. `docs/design/DESIGN-SYSTEM.md` says today that Dot has no brand colour and uses the system accent, and `docs/design-brief.md` says no custom window chrome.

## Decision

- **The default accent is dot-rose.** `AppColor.accent` returns it when the setting is "Dot".
- **The user can choose the macOS accent.** A new Appearance setting, "Accent", has two values: Dot and System. System returns `Color.accentColor`, as today.
- **Every accent role follows `AppColor.accent`.** Selection, links, Tag pills, search matches and toggles use it. No view reads the rose value directly.
- **The window is frosted** (radius 26, material over `color.window`), and popovers float (radius 22). Sidebar and Inspector panels use radius 18, cards 14. This replaces "no custom window chrome" in the design brief.
- **Folder and Tag colours are new tokens** (`folder.*`, `tag.*` in the redesign). They are information, used only for a card's top edge, a dot and a Folder icon.

## Consequences

- `DESIGN-SYSTEM.md` loses its line "Dot has no colour picker and no brand colour". It gains the Accent setting and the new tokens.
- Tokens are added first (`AppBrandColor`, `AppLabelColor`, more `AppSpacing` and `AppRadius` steps). Views move to them one screen at a time.
- `AppColor.accent` and `AppKitColor.accent` are dynamic colours that read `AppAccent.current` as they draw (M9-01).
- `AppColor.onAccent` must change with the accent: `#FFFFFF` on rose in light, `#2A0E1B` on rose in dark.
