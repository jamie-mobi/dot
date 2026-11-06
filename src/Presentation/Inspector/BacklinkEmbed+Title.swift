//
//  BacklinkEmbed+Title.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore

extension BacklinkEmbed {
    var title: String {
        switch self {
        case .note, .heading:
            String(localized: "Embeds")
        case .block:
            String(localized: "Embeds the block")
        }
    }
}
