//
//  WaitingPack.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation

public struct WaitingPack: Hashable, Sendable {
    // MARK: - Stored

    public let folderURL: URL
    public let isNew: Bool
    public let note: NotePath?

    // MARK: - Init

    public init(folderURL: URL, isNew: Bool, note: NotePath? = nil) {
        self.folderURL = folderURL
        self.isNew = isNew
        self.note = note
    }
}
