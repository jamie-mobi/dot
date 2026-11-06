//
//  NoteFileRequest.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore

enum NoteFileRequest: Hashable {
    case rename(NotePath)
    case move(NotePath)
    case trash(NotePath)
}
