//
//  RelativeAgeUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum RelativeAgeUseCase {
    // MARK: - Constants

    private enum Constants {
        static let minute: TimeInterval = 60
        static let hour: TimeInterval = 3600
        static let daysShown = 7
    }

    // MARK: - Age

    public static func age(of date: Date, now: Date, calendar: Calendar = .current) -> RelativeAge {
        let elapsed = max(0, now.timeIntervalSince(date))
        if elapsed < Constants.minute {
            return .now
        }
        if elapsed < Constants.hour {
            return .minutes(Int(elapsed / Constants.minute))
        }
        if calendar.isDate(date, inSameDayAs: now) {
            return .hours(Int(elapsed / Constants.hour))
        }

        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day ?? 0
        switch days {
        case ...1:
            return .yesterday
        case 2 ..< Constants.daysShown:
            return .days(days)
        default:
            return .date(date)
        }
    }
}
