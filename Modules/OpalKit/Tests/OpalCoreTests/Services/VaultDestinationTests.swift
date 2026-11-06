//
//  VaultDestinationTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import OpalCore

@Suite("Home, Search and Note destinations", .tags(.service))
@MainActor
struct VaultDestinationTests {
    @Test("starts on Home and opening a Note shows it")
    func opensNote() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()

        #expect(harness.navigation.destination == .home)
        #expect(harness.navigation.canGoBack == false)

        await harness.navigation.open(NotePath("Soil.md"))

        #expect(harness.navigation.destination == .note)
        #expect(harness.navigation.canGoBack)
    }

    @Test("Back from Search returns to where the user was")
    func backFromSearch() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()
        await harness.navigation.open(NotePath("Soil.md"))

        harness.search.show(query: "soil")
        #expect(harness.navigation.destination == .search)

        await harness.navigation.goBack()
        #expect(harness.navigation.destination == .note)
        #expect(harness.navigation.openNote == NotePath("Soil.md"))
    }

    @Test("Back from the first Note goes Home, and Forward returns to it")
    func backToHome() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()
        await harness.navigation.open(NotePath("Soil.md"))

        await harness.navigation.goBack()
        #expect(harness.navigation.destination == .home)
        #expect(harness.navigation.canGoForward)

        await harness.navigation.goForward()
        #expect(harness.navigation.destination == .note)
        #expect(harness.navigation.openNote == NotePath("Soil.md"))
    }

    @Test("Back between Notes walks the history before going Home")
    func backThroughHistory() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()
        await harness.navigation.open(NotePath("Soil.md"))
        await harness.navigation.open(NotePath("Tomatoes.md"))

        await harness.navigation.goBack()

        #expect(harness.navigation.destination == .note)
        #expect(harness.navigation.openNote == NotePath("Soil.md"))
    }

    @Test("Home with no Note open has nowhere to go forward")
    func homeWithoutNote() async throws {
        let vault = try FixtureVault()
        defer { vault.remove() }
        let harness = ServiceHarness(store: FileSystemVaultStore(rootURL: vault.rootURL))
        await harness.openVault()

        harness.navigation.showSearch()
        await harness.navigation.goBack()

        #expect(harness.navigation.destination == .home)
        #expect(harness.navigation.canGoForward == false)
    }
}
