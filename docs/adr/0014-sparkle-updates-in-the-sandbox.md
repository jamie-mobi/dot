# 0014 — Updates with Sparkle, inside the sandbox

Date: 07/11/2026. Status: accepted (the user asked for Sparkle, a "Check for Updates…" menu item and a check at launch on 07/11/2026).

## Context

Dot ships outside the Mac App Store, so it needs its own updater. Dot is sandboxed (ADR 0001).

## Decision

- **Sparkle 2** (Swift package, `from: 2.10.1`) is the updater. Only `src/App/SparkleUpdater.swift` imports it.
- **`UpdateService`** in DotCore holds `canCheckForUpdates` and the check intent. The app menu reads it. Presentation never sees Sparkle.
- **The feed** is `https://github.com/jamielesouef/dot/releases/latest/download/appcast.xml`. Updates are signed with an EdDSA key kept in the login Keychain under the account `opal`. The public key is `SUPublicEDKey` in `project.yml`.
- **Sandbox:** `SUEnableInstallerLauncherService`, `network.client`, and the mach-lookup exceptions `$(PRODUCT_BUNDLE_IDENTIFIER)-spks` and `-spki`.
- **Dot checks in the background at every launch.** It does not start the updater when a launch argument points defaults, the Index or a snapshot at a test folder, so acceptance runs never touch the network or Sparkle's defaults.

## Consequences

- `CFBundleShortVersionString` and `CFBundleVersion` now come from `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`. Raise `CURRENT_PROJECT_VERSION` for every release: Sparkle compares it.
- Losing the private key means existing installs can not take new updates. Back it up with `generate_keys --account opal -x <file>`.
- A release must be signed with a Developer ID and notarised for the installer to run.
