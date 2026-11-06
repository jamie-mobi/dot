//
//  FixedClock.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
@testable import DotCore

struct FixedClock: Clocking {
    // MARK: - Clocking

    let now: Date
    let timeZone: TimeZone
}
