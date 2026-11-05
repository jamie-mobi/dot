//
//  TypingLayoutUITests.swift
//  Opal
//
//  Created by Jamie Le Souef on 05/11/2026.
//

import XCTest

@MainActor
final class TypingLayoutUITests: XCTestCase {
    // MARK: - Constants

    private enum Constants {
        static let nestedNote = "Projects/Opal/Planning/Quarterly Reviews/2026/Working Notes For The Whole Team.md"
        static let runFolder = "Library/Containers/com.jamielesouef.Opal/Data/tmp/opal-uitest"
        static let keystrokes = Array("typing moves nothing")
        static let samplesPerKeystroke = 6
        static let sampleInterval: TimeInterval = 0.15
    }

    // MARK: - Lifecycle

    override func setUp() async throws {
        continueAfterFailure = true
    }

    // MARK: - Tests

    func testTypingInANoteWithPropertiesKeepsTheLayoutStill() throws {
        let app = try launch(opening: "Welcome.md", copy: "wide")
        let samples = typeAndSample(in: app)
        report(samples)
    }

    func testTypingInADeeplyNestedNoteKeepsTheLayoutStill() throws {
        let app = try launch(opening: Constants.nestedNote, copy: "nested")
        let samples = typeAndSample(in: app)
        report(samples)
    }

    // MARK: - Launch

    private static var realHome: URL {
        guard let entry = getpwuid(getuid()), let directory = entry.pointee.pw_dir else {
            return URL(filePath: NSHomeDirectory(), directoryHint: .isDirectory)
        }

        return URL(filePath: String(cString: directory), directoryHint: .isDirectory)
    }

    private func launch(opening note: String, copy: String) throws -> XCUIApplication {
        let folder = Self.realHome.appending(path: Constants.runFolder).appending(path: copy)
        let vault = folder.appending(path: "Garden")
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: vault.appending(path: note).path(percentEncoded: false)),
            "Run the Opal UI Tests scheme: its pre-action copies the fixture Vault into Opal's container"
        )
        let app = XCUIApplication()
        app.launchArguments = [
            "-OpalVaultPath", vault.path(percentEncoded: false),
            "-OpalIndexFolder", folder.appending(path: "Index").path(percentEncoded: false),
            "-OpalDefaultsSuite", "opal-uitest-\(copy)",
            "-OpalOpenNote", note,
            "-ApplePersistenceIgnoreState", "YES"
        ]
        app.launch()
        XCTAssertTrue(app.textViews.firstMatch.waitForExistence(timeout: 10), "The Editor never appeared")
        XCTAssertTrue(app.staticTexts["Properties"].firstMatch.waitForExistence(timeout: 5), "The Properties block never appeared")
        return app
    }

    // MARK: - Sampling

    private func typeAndSample(in app: XCUIApplication) -> [LayoutSample] {
        let editor = app.textViews.firstMatch
        editor.click()
        editor.typeKey(.downArrow, modifierFlags: .command)
        Thread.sleep(forTimeInterval: 1.5)
        var samples = [sample(app, after: "start", tick: 0)]
        for key in Constants.keystrokes {
            editor.typeText(String(key))
            for tick in 0 ..< Constants.samplesPerKeystroke {
                samples.append(sample(app, after: String(key), tick: tick))
                Thread.sleep(forTimeInterval: Constants.sampleInterval)
            }
        }
        return samples
    }

    private func sample(_ app: XCUIApplication, after key: String, tick: Int) -> LayoutSample {
        let inspector = app.radioButtons["Backlinks"].firstMatch
        let edited = app.staticTexts["Edited"].firstMatch
        return LayoutSample(
            key: key,
            tick: tick,
            window: app.windows.firstMatch.frame,
            editor: app.scrollViews.containing(.textView, identifier: nil).firstMatch.frame,
            text: app.textViews.firstMatch.frame,
            properties: app.staticTexts["Properties"].firstMatch.frame,
            inspector: inspector.exists ? inspector.frame : .null,
            picker: app.radioGroups["Show"].firstMatch.frame,
            isEdited: edited.exists && edited.isHittable
        )
    }

    // MARK: - Report

    private func report(_ samples: [LayoutSample]) {
        let log = samples.map(\.line).joined(separator: "\n")
        let attachment = XCTAttachment(string: log)
        attachment.name = "layout samples"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTContext.runActivity(named: "layout samples\n\(log)") { _ in }

        let editorWidths = Set(samples.map { Int($0.editor.width.rounded()) })
        let editorTops = Set(samples.map { Int($0.editor.minY.rounded()) })
        let propertiesTops = Set(samples.map { Int($0.properties.minY.rounded()) })
        let inspectorLefts = Set(samples.map { Int($0.inspector.minX.rounded()) })
        let pickerWidths = Set(samples.map { Int($0.picker.width.rounded()) })
        XCTAssertEqual(editorWidths.count, 1, "The Editor's width changed while typing: \(editorWidths.sorted())")
        XCTAssertEqual(editorTops.count, 1, "The Editor moved up or down while typing: \(editorTops.sorted())")
        XCTAssertEqual(propertiesTops.count, 1, "The Properties block moved while typing: \(propertiesTops.sorted())")
        XCTAssertEqual(inspectorLefts.count, 1, "The Inspector's left edge moved while typing: \(inspectorLefts.sorted())")
        XCTAssertEqual(pickerWidths.count, 1, "The Inspector's pane picker changed width while typing: \(pickerWidths.sorted())")
    }
}
