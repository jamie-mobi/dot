//
//  RelativeAgeUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("RelativeAgeUseCase", .tags(.domain))
struct RelativeAgeUseCaseTests {
    // MARK: - Helpers

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    // MARK: - Tests

    @Test("under a minute is now, and a date in the future is now too")
    func now() {
        #expect(RelativeAgeUseCase.age(of: date(3, 12, 0), now: date(3, 12, 0), calendar: calendar) == .now)
        #expect(RelativeAgeUseCase.age(of: date(3, 13, 0), now: date(3, 12, 0), calendar: calendar) == .now)
    }

    @Test("minutes, then hours on the same day")
    func minutesAndHours() {
        #expect(RelativeAgeUseCase.age(of: date(3, 11, 58), now: date(3, 12, 0), calendar: calendar) == .minutes(2))
        #expect(RelativeAgeUseCase.age(of: date(3, 9, 0), now: date(3, 12, 0), calendar: calendar) == .hours(3))
    }

    @Test("an edit late yesterday is Yesterday, even under 24 hours ago")
    func yesterday() {
        #expect(RelativeAgeUseCase.age(of: date(2, 23, 0), now: date(3, 9, 0), calendar: calendar) == .yesterday)
    }

    @Test("days up to a week, then the date")
    func daysThenDate() {
        #expect(RelativeAgeUseCase.age(of: date(1, 9, 0), now: date(3, 9, 0), calendar: calendar) == .days(2))
        #expect(RelativeAgeUseCase.age(of: calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 9)) ?? .distantPast, now: date(3, 9, 0), calendar: calendar) == .date(calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 9)) ?? .distantPast))
    }
}
