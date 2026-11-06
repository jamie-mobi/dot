//
//  AppAccent+Title.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotDesign

extension AppAccent {
    var title: String {
        switch self {
        case .dot:
            String(localized: "Dot")
        case .system:
            String(localized: "System")
        }
    }
}
