//
//  Block.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public struct Block: Hashable, Sendable, Codable {
    // MARK: - Stored

    public let id: String
    public let line: Int
    public let text: String

    // MARK: - Init

    public init(id: String, line: Int, text: String = "") {
        self.id = id
        self.line = line
        self.text = text
    }
}
