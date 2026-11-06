//
//  PackFileStoring.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public protocol PackFileStoring: Sendable {
    var rootURL: URL { get }

    func listEntries() async throws(PackError) -> [PackEntry]
    func readNote(at path: NotePath) async throws(PackError) -> String?
    func noteStamps() async throws(PackError) -> [NotePath: FileStamp]
    func stamp(of path: NotePath) async -> FileStamp?
    func created(of path: NotePath) async -> Date?
    func writeNote(_ text: String, at path: NotePath) async throws(PackError)
    func createNote(at path: NotePath, text: String) async throws(PackError)
    func createFolder(at path: NotePath) async throws(PackError)
    func moveItem(from source: NotePath, to destination: NotePath) async throws(PackError)
    func trashItem(at path: NotePath) async throws(PackError)
    func createFile(at path: NotePath, data: Data) async throws(PackError)
    func readObsidianSettings(named fileName: String) async -> Data?
    func url(for path: NotePath) -> URL
}

extension PackFileStoring {
    public func created(of _: NotePath) async -> Date? {
        nil
    }
}
