//
//  RelativeAge+Text.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore

extension RelativeAge {
    var shortText: String {
        switch self {
        case .now:
            String(localized: "Now")
        case let .minutes(count):
            String(localized: "\(count) min")
        case let .hours(count):
            String(localized: "\(count) h")
        case .yesterday:
            String(localized: "Yesterday")
        case let .days(count):
            String(localized: "\(count) days")
        case let .date(date):
            date.formatted(.dateTime.day().month(.abbreviated))
        }
    }
}
