//
//  PackWatching.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public protocol PackWatching: Sendable {
    func changes() -> AsyncStream<Set<NotePath>>
}
