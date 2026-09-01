//
//  GalleryView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import SwiftUI

struct GalleryView: View {

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                Color.blue.opacity(0.6)
                Color.green.opacity(0.4)
                Color.red.opacity(0.4)
                Color.orange.opacity(0.4)
                Color.blue.opacity(0.4)
            }
            .tabViewStyle(.page)
            .frame(height: 340)
            
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(.white.opacity(0.9), in: Circle())
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "heart")
                        .padding(10)
                        .background(.white.opacity(0.9), in: Circle())
                }
            }
            .padding()
            .padding(.top, 40)
        }
        
        
    }
    
}
