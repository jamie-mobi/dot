//
//  PackError+Message.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore

extension PackError {
    // MARK: - Message

    var message: String {
        switch self {
        case .folderUnreadable:
            String(localized: "Dot can’t read this folder. Check that it exists and that you have access to it.")
        case .accessDenied:
            String(localized: "Dot doesn’t have permission to use this folder. Choose it again to give access.")
        case .packMissing:
            String(localized: "The Pack you used last can’t be found. It may have been moved or deleted.")
        case .noPackOpen:
            String(localized: "No Pack is open.")
        case .outsidePack:
            String(localized: "This file is outside the Pack, so Dot won’t open it.")
        case let .notFound(path):
            String(localized: "“\(path.name)” no longer exists.")
        case let .unreadable(path):
            String(localized: "Dot can’t read “\(path.name)”.")
        case let .notUTF8(path):
            String(localized: "“\(path.name)” isn’t UTF-8 text, so Dot won’t open it to avoid changing it.")
        case let .writeFailed(path):
            String(localized: "Dot couldn’t save “\(path.name)”. Your edits are still here.")
        case let .alreadyExists(path):
            String(localized: "“\(path.fileName)” already exists.")
        }
    }
}
