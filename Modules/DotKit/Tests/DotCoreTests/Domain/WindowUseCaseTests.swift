//
//  WindowUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Testing
@testable import DotCore

@Suite("Window use cases", .tags(.domain))
struct WindowUseCaseTests {
    @Test("shows an Attachment's panel only when an Attachment is selected")
    func detailContent() {
        let image = NotePath("Attachments/seedlings.png")

        #expect(DetailContentUseCase.content(selection: image, kind: .attachment) == .attachment(image))
        #expect(DetailContentUseCase.content(selection: NotePath("Soil.md"), kind: .note) == .note)
        #expect(DetailContentUseCase.content(selection: NotePath("Areas"), kind: .folder) == .note)
        #expect(DetailContentUseCase.content(selection: nil, kind: nil) == .note)
    }

    @Test("titles the window with the open Note, and its subtitle with the Pack and Folder")
    func title() {
        let note = NotePath("Projects/Dot/Dot Roadmap.md")

        #expect(WindowTitleUseCase.title(packName: "Garden", openNote: note) == "Dot Roadmap")
        #expect(WindowTitleUseCase.subtitle(packName: "Garden", openNote: note) == "Garden/Projects/Dot")
        #expect(WindowTitleUseCase.subtitle(packName: "Garden", openNote: NotePath("Soil.md")) == "Garden")
        #expect(WindowTitleUseCase.title(packName: "Garden", openNote: nil) == "Garden")
        #expect(WindowTitleUseCase.subtitle(packName: "Garden", openNote: nil) == "")
    }
}
