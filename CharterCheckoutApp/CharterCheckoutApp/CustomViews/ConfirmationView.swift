//
//  ConfirmationView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

struct ConfirmationView: View {
    
    let viewModel: CheckoutViewModel
    let onDone: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)
                    .accessibilityIdentifier("confirmation_success_icon")
                Text(Strings.Confirmation.bookingConfirmedTitle)
                    .font(.title2.bold())
                    .accessibilityIdentifier("confirmation_title")
                if let reference = viewModel.bookingReference {
                    Text(Strings.Confirmation.referenceLabel(reference))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("booking_reference_label")
                }
                
                TripSummaryCard(package: viewModel.package, groupSize: viewModel.groupSize) {
                    Text(viewModel.paymentOption.label)
                        .font(.caption).foregroundStyle(.secondary)
                }
                
                PrimaryButton(title: Strings.Confirmation.done, identifier: "done_button", action: onDone)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
