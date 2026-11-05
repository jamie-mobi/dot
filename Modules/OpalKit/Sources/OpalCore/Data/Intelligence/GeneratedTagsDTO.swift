//
//  GeneratedTagsDTO.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import FoundationModels

@Generable(description: "Tags that describe what a Note is about")
struct GeneratedTagsDTO {
    // MARK: - Stored

    @Guide(description: "Short lowercase tags, one to three words each, joined with hyphens, without a leading #", .maximumCount(8))
    let tags: [String]
}
