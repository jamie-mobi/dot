//
//  AppAccent+Title.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalDesign

extension AppAccent {
    var title: String {
        switch self {
        case .opal:
            String(localized: "Opal")
        case .system:
            String(localized: "System")
        }
    }
}
