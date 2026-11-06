//
//  NotePreviewLine.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

public struct NotePreviewLine: Hashable, Sendable {
    // MARK: - Stored

    public let text: String
    public let isBullet: Bool

    // MARK: - Init

    public init(text: String, isBullet: Bool = false) {
        self.text = text
        self.isBullet = isBullet
    }
}
