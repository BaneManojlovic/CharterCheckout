//
//  CharterCheckoutAppTests.swift
//  CharterCheckoutAppTests
//
//  Created by Branislav Manojlovic on 3. 9. 2026..
//

import Testing
import Foundation

@testable import CharterCheckoutApp

struct CheckoutViewModelTests {

    private func makeViewModel() -> CheckoutViewModel {
        let package = Package(
            id: "1", title: "Test Trip", description: "desc",
            price: 500, currency: "USD", hours: 4,
            minPersons: 1, maxPersons: 4, packageType: "D"
        )
        return CheckoutViewModel(package: package, date: Date(), groupSize: 2)
    }

    @Test func emptyFormIsInvalid() {
        let vm = makeViewModel()
        #expect(!vm.isFormValid)
    }

    @Test func validEmailPasses() {
        let vm = makeViewModel()
        vm.customer.email = "test@example.com"
        #expect(vm.isEmailValid)
    }

    @Test func emailWithoutAtSignFails() {
        let vm = makeViewModel()
        vm.customer.email = "not-an-email"
        #expect(!vm.isEmailValid)
    }

    @Test func cardNumberTooShortFails() {
        let vm = makeViewModel()
        vm.card.number = "1234"
        #expect(!vm.isCardNumberValid)
    }

    @Test func validCardNumberPasses() {
        let vm = makeViewModel()
        vm.card.number = "4111 1111 1111 1111"
        #expect(vm.isCardNumberValid)
    }

    @Test func expiryMonthOutOfRangeFails() {
        let vm = makeViewModel()
        vm.card.expiry = "13/29"
        #expect(!vm.isExpiryValid)
    }

    @Test func depositIsTwentyPercentOfPrice() {
        let vm = makeViewModel()
        #expect(vm.depositAmount == 100)
        #expect(vm.remainingAmount == 400)
    }

    @Test func fullyValidFormPasses() {
        let vm = makeViewModel()
        vm.customer.firstName = "Jane"
        vm.customer.lastName = "Doe"
        vm.customer.email = "jane@example.com"
        vm.customer.phone = "+381621711215"
        vm.card.number = "4111111111111111"
        vm.card.expiry = "09/29"
        vm.card.cvv = "123"
        vm.card.cardholderName = "Jane Doe"
        #expect(vm.isFormValid)
    }
}
