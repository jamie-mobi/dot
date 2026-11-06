//
//  Pack.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public struct Pack: Hashable, Sendable {
    // MARK: - Stored

    public let rootURL: URL

    // MARK: - Init

    public init(rootURL: URL) {
        self.rootURL = rootURL
    }

    // MARK: - Derived

    public var name: String {
        rootURL.lastPathComponent
    }
}
