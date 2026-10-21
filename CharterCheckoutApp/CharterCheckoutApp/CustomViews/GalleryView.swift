//
//  GalleryView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import SwiftUI

struct GalleryView: View {
    let photos: [CharterPhoto]
    let onBackTap: () -> Void
    let onLikeTap: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                if photos.isEmpty {
                    placeholder
                } else {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                        AsyncImage(url: URL(string: photo.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            case .failure:
                                placeholder
                            default:
                                Color(.systemGray5)
                            }
                        }
                        .clipped()
                        // One accessibility element per page, whatever its load phase,
                        // so each page has a stable identity for UI tests and VoiceOver.
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isImage)
                        .accessibilityLabel("Photo \(index + 1) of \(photos.count)")
                        .accessibilityIdentifier("gallery_image_item_\(index)")
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 340)
            .accessibilityIdentifier("gallery_carousel_container")

            HStack {
                Button(action: onBackTap) {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(.white.opacity(0.9), in: Circle())
                }
                .accessibilityIdentifier("gallery_back_button")
                Spacer()
                Button(action: onLikeTap) {
                    Image(systemName: "heart")
                        .padding(10)
                        .background(.white.opacity(0.9), in: Circle())
                }
                .accessibilityIdentifier("gallery_like_button")
            }
            .padding()
            .padding(.top, 40)
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary))
    }
}
