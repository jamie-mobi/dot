//
//  StubPackFileStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
@testable import DotCore

actor StubPackFileStore: PackFileStoring {
    // MARK: - Stored

    nonisolated let rootURL: URL

    private(set) var files: [NotePath: String]
    private(set) var folders: Set<NotePath>
    private(set) var attachments: [NotePath: Data] = [:]
    private(set) var writeCount = 0
    private(set) var listCount = 0

    private var listError: PackError?
    private var readError: PackError?
    private var writeError: PackError?
    private var settingsData: Data?

    // MARK: - Init

    init(
        rootURL: URL = URL(filePath: "/Stub Pack"),
        files: [String: String] = [:],
        folders: [String] = [],
        settingsJSON: String? = nil
    ) {
        self.rootURL = rootURL
        self.files = Dictionary(uniqueKeysWithValues: files.map { (NotePath($0.key), $0.value) })
        self.folders = Set(folders.map(NotePath.init))
        settingsData = settingsJSON.map { Data($0.utf8) }
    }

    // MARK: - PackFileStoring

    func listEntries() throws(PackError) -> [PackEntry] {
        listCount += 1
        if let listError {
            throw listError
        }

        return folders.map { PackEntry(path: $0, kind: .folder) }
            + files.keys.map { PackEntry(path: $0, isFolder: false) }
    }

    func noteStamps() throws(PackError) -> [NotePath: FileStamp] {
        Dictionary(uniqueKeysWithValues: files.filter { $0.key.isNote }.map { ($0.key, Self.stamp(for: $0.value)) })
    }

    func stamp(of path: NotePath) -> FileStamp? {
        files[path].map(Self.stamp(for:))
    }

    private static func stamp(for text: String) -> FileStamp {
        FileStamp(modified: Date(timeIntervalSince1970: Double(text.hashValue & 0xFFFF)), size: text.utf8.count)
    }

    func readNote(at path: NotePath) throws(PackError) -> String? {
        if let readError {
            throw readError
        }

        return files[path]
    }

    func writeNote(_ text: String, at path: NotePath) throws(PackError) {
        if let writeError {
            throw writeError
        }

        writeCount += 1
        files[path] = text
    }

    func createNote(at path: NotePath, text: String) throws(PackError) {
        guard files[path] == nil else {
            throw .alreadyExists(path)
        }

        files[path] = text
    }

    func createFile(at path: NotePath, data: Data) throws(PackError) {
        guard files[path] == nil, attachments[path] == nil else {
            throw .alreadyExists(path)
        }

        attachments[path] = data
    }

    func trashItem(at path: NotePath) throws(PackError) {
        guard files.removeValue(forKey: path) != nil || folders.remove(path) != nil else {
            throw .notFound(path)
        }
    }

    func moveItem(from source: NotePath, to destination: NotePath) throws(PackError) {
        guard let text = files.removeValue(forKey: source) else {
            throw .notFound(source)
        }

        files[destination] = text
    }

    func createFolder(at path: NotePath) throws(PackError) {
        guard folders.contains(path) == false else {
            throw .alreadyExists(path)
        }

        folders.insert(path)
    }

    func readObsidianSettings(named fileName: String) -> Data? {
        settingsData
    }

    nonisolated func url(for path: NotePath) -> URL {
        rootURL.appending(path: path.rawValue)
    }

    // MARK: - Test configuration

    func changeOnDisk(_ raw: String, to text: String?) {
        files[NotePath(raw)] = text
    }

    func failLists(with error: PackError?) {
        listError = error
    }

    func failReads(with error: PackError?) {
        readError = error
    }

    func failWrites(with error: PackError?) {
        writeError = error
    }

    func text(_ raw: String) -> String? {
        files[NotePath(raw)]
    }
}
