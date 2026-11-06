//
//  View+ServiceGraph.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import DotCore
import SwiftUI

extension View {
    // MARK: - Injection

    func serviceGraph(_ graph: ServiceGraph) -> some View {
        environment(\.serviceGraph, graph)
            .environment(\.packService, graph.pack)
            .environment(\.noteService, graph.notes)
            .environment(\.linkService, graph.links)
            .environment(\.indexService, graph.index)
            .environment(\.searchService, graph.search)
            .environment(\.mentionService, graph.mentions)
            .environment(\.dailyNoteService, graph.dailyNotes)
            .environment(\.templateService, graph.templates)
            .environment(\.renameService, graph.renames)
            .environment(\.folderColourService, graph.folderColours)
            .environment(\.starredNoteService, graph.stars)
            .environment(\.navigationService, graph.navigation)
            .environment(\.quickSwitcherService, graph.switcher)
            .environment(\.settingsService, graph.settings)
            .environment(\.tagSuggestionService, graph.tagSuggestions)
    }
}
