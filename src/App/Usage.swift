//
//  Usage.swift
//  Opal
//
//  Created by Jamie Le Souef on 05/11/2026.
//

import FirebaseAnalytics
import FirebaseCore
import Foundation
import OpalCore

@MainActor
enum Usage {
    // MARK: - Constants

    private enum Constants {
        static let debugFlag = "-FIRDebugEnabled"
        static let scriptedRunPrefix = "-Opal"
        static let configName = "GoogleService-Info"
    }

    // MARK: - State

    private static var isOn = false

    // MARK: - Start

    static func start(arguments: [String] = ProcessInfo.processInfo.arguments) {
        let hasConfig = Bundle.main.url(forResource: Constants.configName, withExtension: "plist") != nil
        guard isAllowed(arguments), hasConfig else {
            AppLog.info("Usage analytics are off")
            return
        }

        FirebaseApp.configure()
        isOn = true
    }

    static func isAllowed(_ arguments: [String]) -> Bool {
        #if DEBUG
            arguments.contains(Constants.debugFlag)
        #else
            arguments.contains { $0.hasPrefix(Constants.scriptedRunPrefix) } == false
        #endif
    }

    // MARK: - Events

    static func feature(_ command: AppCommand) {
        log("use_\(command.rawValue)")
    }

    static func screen(_ name: String) {
        log(AnalyticsEventScreenView, [AnalyticsParameterScreenName: name])
    }

    static func log(_ name: String, _ parameters: [String: String] = [:]) {
        guard isOn else {
            return
        }

        Analytics.logEvent(name, parameters: parameters)
    }

    static func countBucket(_ count: Int) -> String {
        switch count {
        case ..<10:
            "0-9"
        case ..<100:
            "10-99"
        case ..<1000:
            "100-999"
        case ..<10000:
            "1000-9999"
        default:
            "10000+"
        }
    }
}
