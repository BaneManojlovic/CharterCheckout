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
                Text("Booking Confirmed!")
                    .font(.title2.bold())
                if let reference = viewModel.bookingReference {
                    Text("Reference: \(reference)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                TripSummaryCard(package: viewModel.package, groupSize: viewModel.groupSize) {
                    Text(viewModel.paymentOption.label)
                        .font(.caption).foregroundStyle(.secondary)
                }
                
                PrimaryButton(title: "Done", action: onDone)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
