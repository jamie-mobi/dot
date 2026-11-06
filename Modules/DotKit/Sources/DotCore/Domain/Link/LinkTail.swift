//
//  LinkTail.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct LinkTail: Hashable, Sendable {
    // MARK: - Stored

    public let length: Int
    public let alias: String?

    // MARK: - Init

    public init(length: Int, alias: String?) {
        self.length = length
        self.alias = alias
    }
}
