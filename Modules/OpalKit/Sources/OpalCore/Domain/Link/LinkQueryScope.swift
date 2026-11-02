//
//  LinkQueryScope.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum LinkQueryScope: Hashable, Sendable {
    case notes
    case headings(of: String)
    case blocks(of: String)
}
