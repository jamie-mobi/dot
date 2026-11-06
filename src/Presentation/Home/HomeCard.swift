//
//  HomeCard.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import SwiftUI

struct HomeCard: Identifiable, Hashable {
    // MARK: - Properties

    let card: NoteCard
    let colour: Color
    let location: String
    let edited: String

    // MARK: - Identifiable

    var id: NotePath {
        card.path
    }
}
