//
//  RelativeAge.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum RelativeAge: Hashable, Sendable {
    case now
    case minutes(Int)
    case hours(Int)
    case yesterday
    case days(Int)
    case date(Date)
}
