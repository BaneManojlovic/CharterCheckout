//
//  CharterInfoSectionView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import SwiftUI

struct CharterInfoSectionView: View {
    let charter: Charter?
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let charter {
                Text(charter.title.capitalized)
                    .font(.title)
                if let location = charter.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(location)
                        if let rating = charter.rating {
                            Text("·")
                            Image(systemName: "star").foregroundStyle(.orange)
                            Text(String(format: "%.1f", rating))
                        }
                        if let reviewCount = charter.reviewCount {
                            Text("(\(reviewCount))")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("no location specified")
                        if let rating = charter.rating {
                            Text("·")
                            Image(systemName: "star").foregroundStyle(.orange)
                            Text(String(format: "%.1f", rating))
                        } else {
                            Text("·")
                            Image(systemName: "star").foregroundStyle(.orange)
                            Text(String(format: "%.1f", 0))
                        }
                        if let reviewCount = charter.reviewCount {
                            Text("(\(reviewCount))")
                        } else {
                            Text("(0)")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Text(charter.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else if isLoading {
                ProgressView()
            }
        }
    }
}

//#Preview("With location & rating") {
//    CharterInfoSectionView(
//        charter: Charter(
//            title: "Reel Adventures Charter",
//            description: "Join Captain Mike for an unforgettable deep-sea fishing experience aboard our 32-foot vessel.",
//            location: "Key West, Florida",
//            rating: 4.9,
//            reviewCount: 124
//        ),
//        isLoading: false
//    )
//    .padding()
//}
