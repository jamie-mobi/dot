//
//  NoteLocation.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation

public struct NoteLocation: Hashable, Sendable {
    // MARK: - Stored

    public let window: UUID
    public let path: NotePath

    // MARK: - Init

    public init(window: UUID, path: NotePath) {
        self.window = window
        self.path = path
    }
}
