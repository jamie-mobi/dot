//
//  ShortcutConflict.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore

struct ShortcutConflict: Hashable {
    // MARK: - Stored

    let shortcut: CommandShortcut
    let other: AppCommand
}
