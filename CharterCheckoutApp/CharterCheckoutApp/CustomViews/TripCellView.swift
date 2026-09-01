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

    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .top) {
                Text(package.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(formattedPrice)
                        .font(.headline)
                    
                }
            }

            HStack(spacing: 8) {
                Label("\(Int(package.hours)) hours", systemImage: "clock")
//                if let max = package.maxPersons {
                Label("up to \(package.minPersons)", systemImage: "person.2")
//                }
                Spacer()
                Text("per trip")
            }
            .font(.caption)
            .foregroundStyle(Color(.systemGray))
            
            Spacer(minLength: 10)
            
            Button {
                // TODO: - make action
            } label: {
                Text("Reserve")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .controlSize(.large)
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
    
    // TODO: - Move this in helper
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencyCode = package.currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: package.price)) ?? "\(package.price)"
    }
}
