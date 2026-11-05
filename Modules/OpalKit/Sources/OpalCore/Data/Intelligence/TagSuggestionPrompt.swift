//
//  TagSuggestionPrompt.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

enum TagSuggestionPrompt {
    // MARK: - Constants

    static let instructions = """
    You suggest tags for a note in a personal knowledge base. \
    A tag names a topic, project, place, person or kind of note that the text is clearly about. \
    Base every tag on what the note text says. \
    The vault list only shows existing spellings: reuse a vault tag only when the note is clearly about that topic, \
    and never add one just because it is listed. \
    Never repeat a tag the note already has. \
    Fewer, accurate tags are better than many.
    """

    // MARK: - Prompt

    static func prompt(for request: TagSuggestionRequest) -> String {
        var sections = ["Note title: \(request.noteName)"]
        if request.existingTags.isEmpty == false {
            sections.append("Tags the note already has: \(request.existingTags.joined(separator: ", "))")
        }
        if request.vaultTags.isEmpty == false {
            sections.append("Tags used elsewhere in the vault: \(request.vaultTags.joined(separator: ", "))")
        }
        sections.append("Note text:\n\(request.body)")
        return sections.joined(separator: "\n\n")
    }
}
