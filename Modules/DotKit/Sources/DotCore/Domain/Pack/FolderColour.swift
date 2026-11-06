//
//  FolderColour.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum FolderColour: String, CaseIterable, Identifiable, Sendable {
    case blue
    case teal
    case purple
    case amber
    case green
    case slate
    case grey

    // MARK: - Identifiable

    public var id: String {
        rawValue
    }
}
