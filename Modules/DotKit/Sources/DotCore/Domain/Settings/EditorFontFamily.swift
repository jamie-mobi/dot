//
//  EditorFontFamily.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum EditorFontFamily: Hashable, Sendable {
    case none
    case installed(String)
    case missing(String)
}
