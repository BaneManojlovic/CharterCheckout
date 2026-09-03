//
//  CharterInfoViewModel.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import Combine

@Observable
class CharterInfoViewModel {

    var charter: Charter?
    var packages: [Package] = []
    var isLoading = false
    var errorMessage: String?
    var selectedDate: Date = Date()
    var adults: Int = 2
    var children: Int = 0
    var groupSize: Int { adults + children }
    var photos: [CharterPhoto] = []
    var availabilityByPackageId: [String: PackageAvailability] = [:]

    // MARK: - Methods

    func loadInitialData() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            async let charterResult = APIManager.shared.getCharterInfo()
            async let packagesResult = APIManager.shared.getPackages()
            async let photosResult = APIManager.shared.getCharterPhotos()

            charter = try await charterResult
            packages = try await packagesResult
            photos = try await photosResult

            await getAvailability()
        } catch {
            errorMessage = Strings.Errors.couldNotLoadCharter
        }
    }

    func getAvailability() async {
        do {
            availabilityByPackageId = try await APIManager.shared.getPackageAvailabilities(
                date: selectedDate, groupSize: groupSize
            )
        } catch {
            availabilityByPackageId = [:]
        }
    }

    func isAvailable(_ package: Package) -> Bool {
        guard groupSize >= package.minPersons else { return false }
        if let max = package.maxPersons, groupSize > max { return false }
        guard let availability = availabilityByPackageId[package.id] else { return true }
        return availability.available
    }

    func unavailabilityReason(for package: Package) -> String? {
        if groupSize < package.minPersons { return Strings.Charter.minPersonsReason(package.minPersons) }
        if let max = package.maxPersons, groupSize > max { return Strings.Charter.maxPersonsReason(max) }
        if let availability = availabilityByPackageId[package.id], !availability.available {
            return availability.reason == "shortNotice" ? Strings.Charter.tooSoonToBook : Strings.Charter.notAvailable
        }
        return nil
    }
}
