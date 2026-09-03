//
//  CheckoutView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

struct CheckoutView: View {
    @State private var viewModel: CheckoutViewModel
    @State private var isConfirmed = false
    let onDismissToRoot: () -> Void

    init(package: Package, date: Date, groupSize: Int, onDismissToRoot: @escaping () -> Void) {
        _viewModel = State(initialValue: CheckoutViewModel(package: package, date: date, groupSize: groupSize))
        self.onDismissToRoot = onDismissToRoot
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                bookingSummarySection
                customerDetailsSection
                paymentOptionSection
                cardDetailsSection
                submitButton
            }
            .padding()
        }
        .navigationTitle("Checkout")
        .navigationDestination(isPresented: $isConfirmed) {
            ConfirmationView(viewModel: viewModel, onDone: onDismissToRoot)
        }
    }

    private var bookingSummarySection: some View {
        TripSummaryCard(package: viewModel.package, groupSize: viewModel.groupSize) {
            Text(viewModel.date.formattedShort)
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Text("Total")
                Spacer()
                Text(viewModel.package.price.asCurrencyString(code: viewModel.package.currency)).font(.headline)
            }
        }
    }

    private var customerDetailsSection: some View {
        SectionCard(title: "Your Details") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("First name", text: $viewModel.customer.firstName)
                fieldError("First name is required", show: viewModel.hasAttemptedSubmit && !viewModel.isFirstNameValid)
                Divider()

                TextField("Last name", text: $viewModel.customer.lastName)
                fieldError("Last name is required", show: viewModel.hasAttemptedSubmit && !viewModel.isLastNameValid)
                Divider()

                TextField("Email", text: $viewModel.customer.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                fieldError("Enter a valid email address", show: viewModel.hasAttemptedSubmit && !viewModel.isEmailValid)
                Divider()

                TextField("Phone number", text: $viewModel.customer.phone)
                    .keyboardType(.phonePad)
                    .filteringInput($viewModel.customer.phone) { InputFilter.phoneFiltered($0) }
                fieldError("Enter a valid phone number", show: viewModel.hasAttemptedSubmit && !viewModel.isPhoneValid)
            }
        }
    }

    private var paymentOptionSection: some View {
        SectionCard(title: "Payment Option") {
            VStack(spacing: 10) {
                ForEach(PaymentOption.allCases) { option in
                    PaymentOptionRow(
                        option: option,
                        subtitle: subtitle(for: option),
                        isSelected: viewModel.paymentOption == option
                    ) {
                        viewModel.paymentOption = option
                    }
                }
            }
        }
    }

    private var cardDetailsSection: some View {
        SectionCard(title: "Card Details") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Card number", text: $viewModel.card.number)
                    .keyboardType(.numberPad)
                    .filteringInput($viewModel.card.number) { InputFilter.cardNumberFormatted($0) }
                fieldError("Enter a valid card number", show: viewModel.hasAttemptedSubmit && !viewModel.isCardNumberValid)
                Divider()

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("MM/YY", text: $viewModel.card.expiry)
                            .keyboardType(.numberPad)
                            .filteringInput($viewModel.card.expiry) { InputFilter.expiryFormatted($0) }
                        fieldError("Invalid expiry", show: viewModel.hasAttemptedSubmit && !viewModel.isExpiryValid)
                    }
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("CVV", text: $viewModel.card.cvv)
                            .keyboardType(.numberPad)
                            .filteringInput($viewModel.card.cvv) { InputFilter.digitsOnly($0, maxLength: 4) }
                        fieldError("Invalid CVV", show: viewModel.hasAttemptedSubmit && !viewModel.isCVVValid)
                    }
                }
                Divider()

                TextField("Cardholder name", text: $viewModel.card.cardholderName)
                fieldError("Cardholder name is required", show: viewModel.hasAttemptedSubmit && !viewModel.isCardholderNameValid)
            }
        }
    }

    private var submitButton: some View {
        VStack(spacing: 8) {
            if viewModel.hasAttemptedSubmit && !viewModel.isFormValid {
                Text("Please fix the highlighted fields above")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            PrimaryButton(
                title: "Confirm Booking",
                isLoading: viewModel.isSubmitting,
                isDisabled: viewModel.isSubmitting
            ) {
                Task {
                    if await viewModel.attemptSubmit() {
                        isConfirmed = true
                    }
                }
            }
        }
    }

    private func subtitle(for option: PaymentOption) -> String {
        switch option {
        case .full:
            return "Charge \(viewModel.package.price.asCurrencyString(code: viewModel.package.currency)) today"
        case .deposit:
            return "Pay \(viewModel.depositAmount.asCurrencyString(code: viewModel.package.currency)) now, \(viewModel.remainingAmount.asCurrencyString(code: viewModel.package.currency)) due later"
        }
    }

    @ViewBuilder
    private func fieldError(_ message: String, show: Bool) -> some View {
        if show {
            Text(message).font(.caption2).foregroundStyle(.red)
        }
    }
}
