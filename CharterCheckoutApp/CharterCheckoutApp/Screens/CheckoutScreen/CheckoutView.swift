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
            VStack(spacing: 10) {
                TextField("First name", text: $viewModel.customer.firstName)
                Divider()
                TextField("Last name", text: $viewModel.customer.lastName)
                Divider()
                TextField("Email", text: $viewModel.customer.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                Divider()
                TextField("Phone number", text: $viewModel.customer.phone)
                    .keyboardType(.phonePad)
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
            VStack(spacing: 10) {
                TextField("Card number", text: $viewModel.card.number)
                    .keyboardType(.numberPad)
                Divider()
                HStack {
                    TextField("MM/YY", text: $viewModel.card.expiry)
                    Divider()
                    TextField("CVV", text: $viewModel.card.cvv)
                        .keyboardType(.numberPad)
                }
                Divider()
                TextField("Cardholder name", text: $viewModel.card.cardholderName)
            }
        }
    }

    private var submitButton: some View {
        PrimaryButton(
            title: "Confirm Booking",
            isLoading: viewModel.isSubmitting,
            isDisabled: !viewModel.isFormValid || viewModel.isSubmitting
        ) {
            Task {
                await viewModel.submit()
                isConfirmed = true
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
}
