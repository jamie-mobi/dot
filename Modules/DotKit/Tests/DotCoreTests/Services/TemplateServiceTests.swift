//
//  TemplateServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("TemplateService", .tags(.service))
@MainActor
struct TemplateServiceTests {
    @Test("lists the Templates Folder from templates.json and fills a Template for the open Note")
    func templates() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        try FileManager().createDirectory(at: pack.url("Templates/Meetings"), withIntermediateDirectories: true)
        try Data("Meeting on {{date:D MMM}} for {{title}}".utf8).write(to: pack.url("Templates/Meetings/Standup.md"))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Soil.md"))
        let service = harness.graph.templates

        #expect(service.templates == [NotePath("Templates/Daily.md"), NotePath("Templates/Meetings/Standup.md")])
        #expect(await service.filledText(of: NotePath("Templates/Meetings/Standup.md"), for: NotePath("Soil.md")) == "Meeting on 26 Oct for Soil")

        await service.insert(NotePath("Templates/Meetings/Standup.md"))
        #expect(service.insertion?.path == NotePath("Soil.md"))
        #expect(service.insertion?.text == "Meeting on 26 Oct for Soil")
    }

    @Test("reads templates.json formats, and nothing when it is missing")
    func parse() {
        let data = Data(#"{"folder":"Templates","dateFormat":"DD/MM/YYYY","timeFormat":""}"#.utf8)
        #expect(ObsidianTemplatesParser.parse(data) == TemplateSettings(folder: "Templates", dateFormat: "DD/MM/YYYY", timeFormat: "HH:mm"))
        #expect(ObsidianTemplatesParser.parse(nil) == nil)
        #expect(TemplateSettings.defaults.folderPath == nil)
    }
}
