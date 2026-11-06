//
//  PackError.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public enum PackError: Error, Hashable, Sendable {
    case folderUnreadable
    case accessDenied
    case packMissing
    case noPackOpen
    case outsidePack
    case notFound(NotePath)
    case unreadable(NotePath)
    case notUTF8(NotePath)
    case writeFailed(NotePath)
    case alreadyExists(NotePath)
}
