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
    var bookingReference: String?

    init(package: Package, date: Date, groupSize: Int) {
        self.package = package
        self.date = date
        self.groupSize = groupSize
    }

    // 20% deposit — a documented assumption, the API doesn't specify one
    var depositAmount: Double { package.price * 0.2 }
    var remainingAmount: Double { package.price - depositAmount }

    var isFormValid: Bool {
        !customer.firstName.isEmpty &&
        !customer.lastName.isEmpty &&
        customer.email.contains("@") &&
        !customer.phone.isEmpty &&
        !card.number.isEmpty &&
        !card.expiry.isEmpty &&
        !card.cvv.isEmpty
    }

    func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        try? await Task.sleep(nanoseconds: 1_500_000_000) // mocked network delay
        bookingReference = "FB-\(Int.random(in: 100_000...999_999))"
    }
}
