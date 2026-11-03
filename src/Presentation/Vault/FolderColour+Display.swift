//
//  FolderColour+Display.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

extension FolderColour {
    var color: Color {
        switch self {
        case FolderColour.blue:
            AppLabelColor.blue
        case FolderColour.teal:
            AppLabelColor.teal
        case FolderColour.purple:
            AppLabelColor.purple
        case FolderColour.amber:
            AppLabelColor.amber
        case FolderColour.green:
            AppLabelColor.green
        case FolderColour.slate:
            AppLabelColor.slate
        case FolderColour.grey:
            AppLabelColor.grey
        }
    }

    var title: String {
        switch self {
        case FolderColour.blue:
            String(localized: "Blue")
        case FolderColour.teal:
            String(localized: "Teal")
        case FolderColour.purple:
            String(localized: "Purple")
        case FolderColour.amber:
            String(localized: "Amber")
        case FolderColour.green:
            String(localized: "Green")
        case FolderColour.slate:
            String(localized: "Slate")
        case FolderColour.grey:
            String(localized: "Grey")
        }
    }
}
