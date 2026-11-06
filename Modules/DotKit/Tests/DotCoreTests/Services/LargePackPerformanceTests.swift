//
//  LargePackPerformanceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite(
    "Large Pack performance",
    .tags(.performance),
    .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["DOT_PERF"] != nil, "Set DOT_PERF=1 and use -c release")
)
@MainActor
struct LargePackPerformanceTests {
    // MARK: - Constants

    private enum Constants {
        static let noteCount = 10_000
        static let firstIndexLimit = Duration.seconds(20)
        static let reopenLimit = Duration.seconds(1)
        static let searchLimit = Duration.milliseconds(100)
        static let homeLimit = Duration.milliseconds(100)
        static let words = "soil water seed root leaf compost garden harvest tomato pea bean sun rain frost mulch spade trowel bed row weed".split(separator: " ")
    }

    // MARK: - Helpers

    private static func makePack() throws -> URL {
        let root = FileManager().temporaryDirectory.appending(component: "DotLargePack-\(UUID().uuidString)")
        var generator = SystemRandomNumberGenerator()
        for index in 0 ..< Constants.noteCount {
            let folder = root.appending(component: "Area \(index % 40)")
            try FileManager().createDirectory(at: folder, withIntermediateDirectories: true)
            let body = (0 ..< 25).map { _ in
                (0 ..< 14).map { _ in String(Constants.words.randomElement(using: &generator) ?? "soil") }.joined(separator: " ")
            }.joined(separator: ".\n")
            let links = (0 ..< 3).map { _ in "[[Note \(Int.random(in: 0 ..< Constants.noteCount, using: &generator))]]" }.joined(separator: " ")
            let text = "---\ntags: [garden]\n---\n# Note \(index)\n\n\(body)\n\nSee \(links) #topic/soil\n"
            try Data(text.utf8).write(to: folder.appending(component: "Note \(index).md"))
        }
        return root
    }

    private static func open(_ root: URL, indexFolder: URL) async -> (PackService, IndexService, LinkService) {
        let pack = PackService(access: StubPackAccess(), locations: StubPackLocationStore(), launchPackURL: nil) { FileSystemPackStore(rootURL: $0) }
        let index = IndexService(pack: pack) { root throws(IndexError) in
            try GRDBIndexStore(folderURL: IndexLocation.folder(forPackAt: root, in: indexFolder))
        }
        let links = LinkService(pack: pack, index: index)
        await pack.open(folderURL: root)
        return (pack, index, links)
    }

    // MARK: - Test

    @Test("10,000 Notes: first index, reopen with no changes, Search and Pack home stay within budget")
    func largePack() async throws {
        let root = try Self.makePack()
        let indexFolder = FileManager().temporaryDirectory.appending(component: "DotLargeIndex-\(UUID().uuidString)")
        defer {
            try? FileManager().removeItem(at: root)
            try? FileManager().removeItem(at: indexFolder)
        }
        let clock = ContinuousClock()

        let (_, firstIndex, firstLinks) = await Self.open(root, indexFolder: indexFolder)
        let first = await clock.measure {
            await firstIndex.sync()
            await firstLinks.sync()
        }

        let (_, index, links) = await Self.open(root, indexFolder: indexFolder)
        let reopen = await clock.measure {
            await index.sync()
            await links.sync()
        }

        let store = try #require(index.store)
        var hits: [SearchHit] = []
        let search = try await clock.measure {
            hits = try await store.search(SearchQueryUseCase.parse("compost harv"), limit: SearchService.resultLimit)
        }

        let home = PackHomeService(index: index, links: links)
        let homeTime = await clock.measure {
            await home.refresh()
        }

        #expect(home.home.recent.count == PackHomeUseCase.recentCount)
        #expect(homeTime < Constants.homeLimit, "Pack home took \(homeTime)")
        #expect(hits.isEmpty == false)
        #expect(links.map.parsed.count == Constants.noteCount)
        #expect(first < Constants.firstIndexLimit, "First index took \(first)")
        #expect(reopen < Constants.reopenLimit, "Reopen took \(reopen)")
        #expect(search < Constants.searchLimit, "Search took \(search)")
    }
}
