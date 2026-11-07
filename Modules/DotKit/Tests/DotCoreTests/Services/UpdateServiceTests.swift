//
//  UpdateServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 07/11/2026.
//

import Testing
@testable import DotCore

@Suite("Update Service", .tags(.service))
@MainActor
struct UpdateServiceTests {
    // MARK: - Tests

    @Test("It does not check before the updater says it can")
    func doesNotCheckWhenUnavailable() {
        let service = UpdateService()
        var checks = 0
        service.connect { checks += 1 }

        service.checkForUpdates()

        #expect(service.canCheckForUpdates == false)
        #expect(checks == 0)
    }

    @Test("It checks once the updater says it can")
    func checksWhenAvailable() {
        let service = UpdateService()
        var checks = 0
        service.connect { checks += 1 }
        service.setCanCheckForUpdates(true)

        service.checkForUpdates()

        #expect(checks == 1)
    }
}
