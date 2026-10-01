//
//  CharterInfoViewModelTests.swift
//  CharterCheckoutAppTests
//
//  Created by Branislav Manojlovic on 1. 10. 2026..
//

import Testing
import Foundation

@testable import CharterCheckoutApp

struct CharterInfoViewModelTests {
    
    // MARK: Čista logika — dostupnost

    @Test func groupSizeBelowMinimumIsUnavailable() {
        let vm = CharterInfoViewModel(apiManager: MockAPIManager())
        vm.adults = 1
        vm.children = 0
        let package = makePackage(minPersons: 3, maxPersons: 6)
        #expect(!vm.isAvailable(package))
    }

    @Test func groupSizeAboveMaximumIsUnavailable() {
        let vm = CharterInfoViewModel(apiManager: MockAPIManager())
        vm.adults = 8
        let package = makePackage(minPersons: 1, maxPersons: 4)
        #expect(!vm.isAvailable(package))
    }

    @Test func noMaxPersonsLimitDoesNotBlock() {
        let vm = CharterInfoViewModel(apiManager: MockAPIManager())
        vm.adults = 20
        let package = makePackage(minPersons: 1, maxPersons: nil)
        #expect(vm.isAvailable(package))
    }

    @Test func noServerAvailabilityDataDefaultsToAvailable() {
        let vm = CharterInfoViewModel(apiManager: MockAPIManager())
        vm.adults = 2
        let package = makePackage(minPersons: 1, maxPersons: 4)
        // availabilityByPackageId je prazan — odgovor sa servera još nije stigao
        #expect(vm.isAvailable(package))
    }

    @Test func serverMarksPackageUnavailable() {
        let vm = CharterInfoViewModel(apiManager: MockAPIManager())
        vm.adults = 2
        let package = makePackage(id: "42", minPersons: 1, maxPersons: 4)
        vm.availabilityByPackageId = ["42": PackageAvailability(packageId: 42, available: false, reason: "shortNotice")]
        #expect(!vm.isAvailable(package))
        #expect(vm.unavailabilityReason(for: package) == Strings.Charter.tooSoonToBook)
    }

    @Test func genericUnavailableReasonForUnknownCause() {
        let vm = CharterInfoViewModel(apiManager: MockAPIManager())
        vm.adults = 2
        let package = makePackage(id: "7", minPersons: 1, maxPersons: 4)
        vm.availabilityByPackageId = ["7": PackageAvailability(packageId: 7, available: false, reason: "soldOut")]
        #expect(vm.unavailabilityReason(for: package) == Strings.Charter.notAvailable)
    }

    // MARK: Async — loadInitialData

    @Test func loadInitialDataSuccessPopulatesState() async {
        let mock = MockAPIManager()
        mock.charterToReturn = Charter(title: "Maximus", description: "A boat")
        mock.packagesToReturn = [makePackage()]
        mock.availabilityToReturn = ["1": PackageAvailability(packageId: 1, available: true, reason: nil)]

        let vm = CharterInfoViewModel(apiManager: mock)
        await vm.loadInitialData()

        #expect(vm.charter?.title == "Maximus")
        #expect(vm.packages.count == 1)
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
        #expect(vm.availabilityByPackageId.count == 1)
    }

    @Test func loadInitialDataFailureSetsErrorMessage() async {
        let mock = MockAPIManager()
        mock.shouldThrowOnCharterInfo = true

        let vm = CharterInfoViewModel(apiManager: mock)
        await vm.loadInitialData()

        #expect(vm.errorMessage == Strings.Errors.couldNotLoadCharter)
        #expect(vm.charter == nil)
        #expect(vm.isLoading == false)
    }

    // MARK: Async — getAvailability

    @Test func getAvailabilityFailureClearsDictionaryInsteadOfCrashing() async {
        let mock = MockAPIManager()
        mock.shouldThrowOnAvailability = true

        let vm = CharterInfoViewModel(apiManager: mock)
        vm.availabilityByPackageId = ["1": PackageAvailability(packageId: 1, available: true, reason: nil)]
        await vm.getAvailability()

        #expect(vm.availabilityByPackageId.isEmpty)
    }
    
}
