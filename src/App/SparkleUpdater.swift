//
//  SparkleUpdater.swift
//  Dot
//
//  Created by Jamie Le Souef on 07/11/2026.
//

import Foundation
import DotCore
import Sparkle

@MainActor
final class SparkleUpdater {
    // MARK: - Private

    private let controller: SPUStandardUpdaterController
    private let service: UpdateService
    private var observation: NSKeyValueObservation?

    // MARK: - Init

    init(service: UpdateService) {
        self.service = service
        controller = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    }

    // MARK: - Intent

    func start() {
        let updater = controller.updater
        do {
            try updater.start()
        } catch {
            AppLog.error("Starting the updater failed: \(error)")
            return
        }

        observation = updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [service] _, change in
            let canCheck = change.newValue ?? false
            Task { @MainActor in
                service.setCanCheckForUpdates(canCheck)
            }
        }
        service.connect { [controller] in
            controller.checkForUpdates(nil)
        }
        updater.checkForUpdatesInBackground()
    }
}
