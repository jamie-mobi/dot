//
//  BlockCandidate.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct BlockCandidate: Hashable, Sendable {
    // MARK: - Stored

    public let line: Int
    public let text: String

    // MARK: - Init

    public init(line: Int, text: String) {
        self.line = line
        self.text = text
    }
}
