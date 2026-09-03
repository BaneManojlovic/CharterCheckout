//
//  TripCellView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import SwiftUI

struct TripCellView: View {

    let package: Package
    let isAvailable: Bool
    let unavailabilityReason: String?
    let onReserve: () -> Void

    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .top) {
                Text(package.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(package.price.asCurrencyString(code: package.currency))
                        .font(.headline)
                    
                }
            }
            
            HStack(spacing: 8) {
                Label("\(Int(package.hours)) hours", systemImage: "clock")
                if let max = package.maxPersons {
                    Label(Strings.Trip.upToPersonsLabel(max), systemImage: "person.2")
                } else {
                    Label(Strings.Trip.noPersonLimit, systemImage: "person.2")
                }
                Spacer()
                Text(Strings.Trip.perTrip)
            }
            .font(.caption)
            .foregroundStyle(Color(.systemGray))
            
            Spacer(minLength: 10)

            PrimaryButton(title: isAvailable ? Strings.Trip.reserve : (unavailabilityReason ?? Strings.Trip.unavailable),
                          isDisabled: !isAvailable,
                          action: onReserve)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray2), lineWidth: 1)
        )
    }
}
