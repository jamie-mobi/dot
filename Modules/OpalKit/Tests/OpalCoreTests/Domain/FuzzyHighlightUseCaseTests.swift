//
//  FuzzyHighlightUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Testing
@testable import OpalCore

@Suite("FuzzyHighlightUseCase", .tags(.domain))
struct FuzzyHighlightUseCaseTests {
    // MARK: - Tests

    @Test("marks the letters typed, in a run when they are next to each other")
    func run() {
        #expect(FuzzyHighlightUseCase.marked("so", in: "The Soil Book") == [4, 5])
    }

    @Test("marks scattered letters in order when there is no run")
    func scattered() {
        #expect(FuzzyHighlightUseCase.marked("pso", in: "Projects/Opal") == [0, 7, 9])
    }

    @Test("marks nothing when the letters are not all there")
    func none() {
        #expect(FuzzyHighlightUseCase.marked("xyz", in: "Soil").isEmpty)
        #expect(FuzzyHighlightUseCase.marked("", in: "Soil").isEmpty)
    }
}
