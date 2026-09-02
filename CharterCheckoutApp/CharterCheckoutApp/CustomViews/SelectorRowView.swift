//
//  SelectorRowView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import SwiftUI

struct SelectorRowView: View {
    
    let dateLabel: String
    let guestsLabel: String
    let onDateTap: () -> Void
    let onGuestsTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onDateTap) {
                selectorLabel(icon: "calendar", title: "Date", value: dateLabel)
            }
            .buttonStyle(.plain)
            Button(action: onGuestsTap) {
                selectorLabel(icon: "person.2", title: "Guests", value: guestsLabel)
            }
            .buttonStyle(.plain)
        }
    }

    private func selectorLabel(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color(.systemGray))
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Color(.systemGray2))
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color(.black))
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundStyle(Color(.systemGray2))
        }
        .padding(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray)))
        .foregroundStyle(.primary)
    }
    
}
