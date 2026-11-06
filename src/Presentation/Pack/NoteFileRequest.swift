//
//  NoteFileRequest.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore

enum NoteFileRequest: Hashable {
    case rename(NotePath)
    case move(NotePath)
    case trash(NotePath)
}
