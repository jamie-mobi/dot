//
//  BacklinkEmbed.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum BacklinkEmbed: Hashable, Sendable {
    case note
    case heading
    case block

    // MARK: - Init

    public init?(_ link: Link) {
        guard link.isEmbed else {
            return nil
        }

        switch link.subpath {
        case .heading:
            self = .heading
        case .block:
            self = .block
        case nil:
            self = .note
        }
    }
}
