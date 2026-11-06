//
//  RelativeAge+Text.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import DotCore

extension RelativeAge {
    func longText(for date: Date) -> String {
        switch self {
        case .now:
            String(localized: "Just now")
        case .minutes, .hours, .days:
            date.formatted(.relative(presentation: .numeric, unitsStyle: .wide))
        case .yesterday:
            String(localized: "Yesterday")
        case let .date(day):
            day.formatted(.dateTime.day().month(.abbreviated).year())
        }
    }

    func editedText(for date: Date) -> String {
        switch self {
        case .now:
            String(localized: "Edited just now")
        case .minutes, .hours, .days:
            String(localized: "Edited \(date.formatted(.relative(presentation: .numeric, unitsStyle: .wide)))")
        case .yesterday:
            String(localized: "Edited yesterday")
        case let .date(day):
            String(localized: "Edited \(day.formatted(.dateTime.day().month(.abbreviated).year()))")
        }
    }

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
