//
//  TripSummaryCard.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

struct TripSummaryCard<Content: View>: View {
    let package: Package
    let groupSize: Int
    @ViewBuilder let extraContent: Content

    var body: some View {
        SectionCard(title: Strings.Trip.yourTrip) {
            VStack(alignment: .leading, spacing: 6) {
                Text(package.title).font(.subheadline.bold())
                Text(Strings.Trip.guestsCountLabel(groupSize))
                    .font(.caption).foregroundStyle(.secondary)
                extraContent
            }
        }
    }
}
