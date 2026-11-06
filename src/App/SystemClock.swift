//
//  SystemClock.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import DotCore

struct SystemClock: Clocking {
    // MARK: - Clocking

    var now: Date {
        .now
    }

    var timeZone: TimeZone {
        .current
    }
}
