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
        case .blue:
            AppLabelColor.blue
        case .teal:
            AppLabelColor.teal
        case .purple:
            AppLabelColor.purple
        case .amber:
            AppLabelColor.amber
        case .green:
            AppLabelColor.green
        case .slate:
            AppLabelColor.slate
        case .grey:
            AppLabelColor.grey
        }
    }

    var title: String {
        switch self {
        case .blue:
            String(localized: "Blue")
        case .teal:
            String(localized: "Teal")
        case .purple:
            String(localized: "Purple")
        case .amber:
            String(localized: "Amber")
        case .green:
            String(localized: "Green")
        case .slate:
            String(localized: "Slate")
        case .grey:
            String(localized: "Grey")
        }
    }
}
