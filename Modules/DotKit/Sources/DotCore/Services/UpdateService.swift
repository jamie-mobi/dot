//
//  UpdateService.swift
//  Dot
//
//  Created by Jamie Le Souef on 07/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class UpdateService {
    // MARK: - State

    public private(set) var canCheckForUpdates = false

    // MARK: - Private

    @ObservationIgnored private var check: @MainActor () -> Void = {}

    // MARK: - Init

    public init() {}

    // MARK: - Wiring

    public func connect(check: @escaping @MainActor () -> Void) {
        self.check = check
    }

    public func setCanCheckForUpdates(_ canCheck: Bool) {
        canCheckForUpdates = canCheck
    }

    // MARK: - Intent

    public func checkForUpdates() {
        guard canCheckForUpdates else {
            return
        }

        check()
    }
}
