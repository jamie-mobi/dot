//
//  AttachmentServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Attachments", .tags(.service))
@MainActor
struct AttachmentServiceTests {
    @Test("a pasted image is saved next to the others and never replaces a file")
    func paste() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let folder = pack.url(".obsidian")
        try Data(#"{"attachmentFolderPath":"Attachments"}"#.utf8).write(to: folder.appending(path: "app.json"))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Welcome.md"))
        let original = try Data(contentsOf: pack.url("Attachments/seedlings.png"))

        let pasted = await harness.notes.attach(Data([1, 2, 3]), named: nil)
        let dropped = await harness.notes.attach(Data([4, 5]), named: "seedlings.png")

        #expect(pasted == "![[Pasted image 20261026183320.png]]")
        #expect(try Data(contentsOf: pack.url("Attachments/Pasted image 20261026183320.png")) == Data([1, 2, 3]))
        #expect(dropped == "![[seedlings 1.png]]")
        #expect(try Data(contentsOf: pack.url("Attachments/seedlings.png")) == original)
        #expect(harness.pack.kind(of: NotePath("Attachments/seedlings 1.png")) == .attachment)
    }
}
