//
//  MockAPIManager.swift
//  CharterCheckoutAppTests
//
//  Created by Branislav Manojlovic on 1. 10. 2026..
//

import Foundation

@testable import CharterCheckoutApp

final class MockAPIManager: APIManagerProtocol {
    var charterToReturn = Charter(title: "Test Charter", description: "Test description")
    var packagesToReturn: [Package] = []
    var photosToReturn: [CharterPhoto] = []
    var availabilityToReturn: [String: PackageAvailability] = [:]

    var shouldThrowOnCharterInfo = false
    var shouldThrowOnAvailability = false

    enum MockError: Error { case simulatedFailure }

    func getCharterInfo() async throws -> Charter {
        if shouldThrowOnCharterInfo { throw MockError.simulatedFailure }
        return charterToReturn
    }

    func getPackages() async throws -> [Package] {
        packagesToReturn
    }

    func getCharterPhotos() async throws -> [CharterPhoto] {
        photosToReturn
    }

    func getPackageAvailabilities(date: Date, groupSize: Int) async throws -> [String: PackageAvailability] {
        if shouldThrowOnAvailability { throw MockError.simulatedFailure }
        return availabilityToReturn
    }
}
