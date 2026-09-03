//
//  CheckoutViewModel.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

@Observable
final class CheckoutViewModel {

    let package: Package
    let date: Date
    let groupSize: Int

    var customer = CustomerDetails()
    var card = CreditCardDetails()
    var paymentOption: PaymentOption = .full

    var isSubmitting = false
    var hasAttemptedSubmit = false
    var bookingReference: String?

    init(package: Package, date: Date, groupSize: Int) {
        self.package = package
        self.date = date
        self.groupSize = groupSize
    }


    var depositAmount: Double { package.price * 0.2 }
    var remainingAmount: Double { package.price - depositAmount }

    // MARK: - Field validation

    var isFirstNameValid: Bool { !customer.firstName.trimmingCharacters(in: .whitespaces).isEmpty }
    var isLastNameValid: Bool { !customer.lastName.trimmingCharacters(in: .whitespaces).isEmpty }

    var isEmailValid: Bool {
        let email = customer.email
        return email.contains("@") && email.contains(".") && !email.hasPrefix("@") && !email.hasSuffix(".")
    }

    var isPhoneValid: Bool { customer.phone.filter(\.isNumber).count >= 6 }

    var isCardNumberValid: Bool {
        let digits = card.number.filter(\.isNumber).count
        return digits >= 13 && digits <= 19
    }

    var isExpiryValid: Bool {
        let parts = card.expiry.split(separator: "/")
        guard parts.count == 2, let month = Int(parts[0]), (1...12).contains(month) else { return false }
        return parts[1].count == 2
    }

    var isCVVValid: Bool {
        let count = card.cvv.filter(\.isNumber).count
        return count == 3 || count == 4
    }

    var isCardholderNameValid: Bool { !card.cardholderName.trimmingCharacters(in: .whitespaces).isEmpty }

    var isFormValid: Bool {
        isFirstNameValid && isLastNameValid && isEmailValid && isPhoneValid &&
        isCardNumberValid && isExpiryValid && isCVVValid && isCardholderNameValid
    }

    // MARK: - Submit

    func attemptSubmit() async -> Bool {
        guard isFormValid else {
            hasAttemptedSubmit = true
            return false
        }
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 1_500_000_000) // mocked network delay
        bookingReference = "FB-\(Int.random(in: 100_000...999_999))"
        return true
    }
}
