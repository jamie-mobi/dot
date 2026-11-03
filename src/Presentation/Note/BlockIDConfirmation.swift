//
//  BlockIDConfirmation.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import OpalCore

@MainActor
enum BlockIDConfirmation {
    // MARK: - Confirm

    static func confirm(_ plan: BlockIDPlan, in window: NSWindow?) async -> Bool {
        let alert = NSAlert()
        alert.messageText = String(localized: "Add a Block id to “\(plan.path.name)”?")
        alert.informativeText = String(localized: "Opal adds ^\(plan.id) to the end of this paragraph in \(plan.path.name), so the Link can point at it. Nothing else in the Note changes.")
        alert.addButton(withTitle: String(localized: "Add Id and Link"))
        alert.addButton(withTitle: String(localized: "Cancel"))
        guard let window else {
            return alert.runModal() == .alertFirstButtonReturn
        }

        return await alert.beginSheetModal(for: window) == .alertFirstButtonReturn
    }
}
