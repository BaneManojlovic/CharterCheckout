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
        .navigationTitle(Strings.Checkout.title)
        .navigationDestination(isPresented: $isConfirmed) {
            ConfirmationView(viewModel: viewModel, onDone: onDismissToRoot)
        }
    }

    private var bookingSummarySection: some View {
        TripSummaryCard(package: viewModel.package, groupSize: viewModel.groupSize) {
            Text(viewModel.date.formattedShort)
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Text(Strings.Checkout.totalLabel)
                Spacer()
                Text(viewModel.package.price.asCurrencyString(code: viewModel.package.currency)).font(.headline)
            }
        }
    }

    private var customerDetailsSection: some View {
        SectionCard(title: Strings.Checkout.yourDetails) {
            VStack(alignment: .leading, spacing: 10) {
                TextField(Strings.Checkout.firstNamePlaceholder, text: $viewModel.customer.firstName)
                fieldError(Strings.Checkout.firstNameRequired, show: viewModel.hasAttemptedSubmit && !viewModel.isFirstNameValid)
                Divider()

                TextField(Strings.Checkout.lastNamePlaceholder, text: $viewModel.customer.lastName)
                fieldError(Strings.Checkout.lastNameRequired, show: viewModel.hasAttemptedSubmit && !viewModel.isLastNameValid)
                Divider()

                TextField(Strings.Checkout.emailPlaceholder, text: $viewModel.customer.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                fieldError(Strings.Checkout.emailInvalid, show: viewModel.hasAttemptedSubmit && !viewModel.isEmailValid)
                Divider()

                TextField(Strings.Checkout.phonePlaceholder, text: $viewModel.customer.phone)
                    .keyboardType(.phonePad)
                    .filteringInput($viewModel.customer.phone) { InputFilter.phoneFiltered($0) }
                fieldError(Strings.Checkout.phoneInvalid, show: viewModel.hasAttemptedSubmit && !viewModel.isPhoneValid)
            }
        }
    }

    private var paymentOptionSection: some View {
        SectionCard(title: Strings.Checkout.paymentOption) {
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
        SectionCard(title: Strings.Checkout.cardDetails) {
            VStack(alignment: .leading, spacing: 10) {
                TextField(Strings.Checkout.cardNumberPlaceholder, text: $viewModel.card.number)
                    .keyboardType(.numberPad)
                    .filteringInput($viewModel.card.number) { InputFilter.cardNumberFormatted($0) }
                fieldError(Strings.Checkout.cardNumberInvalid, show: viewModel.hasAttemptedSubmit && !viewModel.isCardNumberValid)
                Divider()

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField(Strings.Checkout.expiryPlaceholder, text: $viewModel.card.expiry)
                            .keyboardType(.numberPad)
                            .filteringInput($viewModel.card.expiry) { InputFilter.expiryFormatted($0) }
                        fieldError(Strings.Checkout.expiryInvalid, show: viewModel.hasAttemptedSubmit && !viewModel.isExpiryValid)
                    }
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        TextField(Strings.Checkout.cvvPlaceholder, text: $viewModel.card.cvv)
                            .keyboardType(.numberPad)
                            .filteringInput($viewModel.card.cvv) { InputFilter.digitsOnly($0, maxLength: 4) }
                        fieldError(Strings.Checkout.cvvInvalid, show: viewModel.hasAttemptedSubmit && !viewModel.isCVVValid)
                    }
                }
                Divider()

                TextField(Strings.Checkout.cardholderNamePlaceholder, text: $viewModel.card.cardholderName)
                fieldError(Strings.Checkout.cardholderNameRequired, show: viewModel.hasAttemptedSubmit && !viewModel.isCardholderNameValid)
            }
        }
    }

    private var submitButton: some View {
        VStack(spacing: 8) {
            if viewModel.hasAttemptedSubmit && !viewModel.isFormValid {
                Text(Strings.Checkout.fixHighlightedFields)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            PrimaryButton(
                title: Strings.Checkout.confirmBooking,
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
            return Strings.Checkout.chargeTodayLabel(
                viewModel.package.price.asCurrencyString(code: viewModel.package.currency)
            )
        case .deposit:
            return Strings.Checkout.depositLabel(
                depositAmount: viewModel.depositAmount.asCurrencyString(code: viewModel.package.currency),
                remainingAmount: viewModel.remainingAmount.asCurrencyString(code: viewModel.package.currency)
            )
        }
    }

    @ViewBuilder
    private func fieldError(_ message: String, show: Bool) -> some View {
        if show {
            Text(message).font(.caption2).foregroundStyle(.red)
        }
    }
}
