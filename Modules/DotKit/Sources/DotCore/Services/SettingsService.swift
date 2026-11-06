//
//  SettingsService.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class SettingsService {
    // MARK: - State

    public var settings: DotSettings {
        didSet {
            guard settings != oldValue else {
                return
            }

            for pack in packs {
                pack.dotSettings = settings
            }
            store.setSettings(settings)
        }
    }

    public private(set) var activePack: PackService?

    public var packSettings: PackSettings {
        activePack?.packSettings ?? PackSettings()
    }

    public var isPackOpen: Bool {
        activePack?.isOpen == true
    }

    // MARK: - Private

    private let store: any SettingsStoring
    private let clock: any Clocking
    private var packs: [PackService] = []

    // MARK: - Init

    public init(store: any SettingsStoring, clock: any Clocking) {
        self.store = store
        self.clock = clock
        settings = store.settings()
    }

    // MARK: - Packs

    public func attach(_ pack: PackService) {
        pack.dotSettings = settings
        if packs.contains(where: { $0 === pack }) == false {
            packs.append(pack)
        }
        activePack = pack
    }

    public func activate(_ pack: PackService) {
        if packs.contains(where: { $0 === pack }) {
            activePack = pack
        }
    }

    public func detach(_ pack: PackService) {
        packs.removeAll { $0 === pack }
        if activePack === pack {
            activePack = packs.last
        }
    }

    // MARK: - Reads

    public func dailyNotePreview(format: String) -> String {
        MomentFormatUseCase.string(from: clock.now, format: format.isEmpty ? DailyNoteSettings.defaults.format : format, timeZone: clock.timeZone)
    }
}
