//
//  ContentView.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 31. 8. 2026..
//

import SwiftUI
import SwiftData

struct CharterInfoView: View {
    
    @State private var charterInfoViewModel = CharterInfoViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GalleryView()
                
                VStack(alignment: .leading, spacing: 16) {
                    CharterInfoSectionView(charter: charterInfoViewModel.charter,
                                           isLoading: charterInfoViewModel.isLoading)
                    SelectorRowView()
                    packagesSection
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .ignoresSafeArea(edges: .top)
        .task {
            await charterInfoViewModel.getCharterInfo()
            await charterInfoViewModel.getPackagesList()
        }
    }

    // MARK: - 3. Packages
    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available trips")
                .font(.headline)
            
            ForEach(charterInfoViewModel.packages) { package in
                TripCellView(package: package)
            }
        }
    }
    
}
