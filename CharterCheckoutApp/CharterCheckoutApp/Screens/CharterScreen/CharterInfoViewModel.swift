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
    
    func getCharterInfo() async {
        isLoading = true
        defer { isLoading = false }
        do {
            charter = try await APIManager.shared.getCharterInfo()
        } catch {
            errorMessage = "Couldn't load charter info."
        }
    }
    
    func getPackagesList() async {
        isLoading = true
        defer { isLoading = false }
        do {
            packages = try await APIManager.shared.getPackages()
        } catch {
            errorMessage = "Couldn't load trips."
        }
    }
    
    func getPhotos() async {
        do {
            photos = try await APIManager.shared.getCharterPhotos()
                .sorted { $0.cardinal < $1.cardinal }
        } catch {
            errorMessage = "Couldn't load photos."
        }
    }
    
    func getAvailability() async {
        do {
            availabilityByPackageId = try await APIManager.shared.getPackageAvailabilities(
                date: selectedDate,
                groupSize: groupSize
            )
        } catch {
            errorMessage = "Couldn't load availability."
        }
    }

    func isAvailable(_ package: Package) -> Bool {
        guard groupSize >= package.minPersons else { return false }
        if let max = package.maxPersons, groupSize > max { return false }
        // no server data yet (still loading) → don't wrongly block the user
        guard let availability = availabilityByPackageId[package.id] else { return true }
        return availability.available
    }

    func unavailabilityReason(for package: Package) -> String? {
        if groupSize < package.minPersons { return "Min \(package.minPersons) people" }
        if let max = package.maxPersons, groupSize > max { return "Max \(max) people" }
        if let availability = availabilityByPackageId[package.id], !availability.available {
            return availability.reason == "shortNotice" ? "Too soon to book" : "Not available"
        }
        return nil
    }
}
