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
                    ForEach(photos) { photo in
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
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 340)

            HStack {
                Button(action: onBackTap) {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(.white.opacity(0.9), in: Circle())
                }
                Spacer()
                Button(action: onLikeTap) {
                    Image(systemName: "heart")
                        .padding(10)
                        .background(.white.opacity(0.9), in: Circle())
                }
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
