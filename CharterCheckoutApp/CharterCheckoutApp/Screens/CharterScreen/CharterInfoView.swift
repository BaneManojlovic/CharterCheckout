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
    @State private var showDatePicker = false
    @State private var showGroupSizePicker = false
    @State private var showAlert = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: charterInfoViewModel.selectedDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GalleryView(onBackTap: { showAlert = true },
                            onLikeTap: { showAlert = true })
                
                VStack(alignment: .leading, spacing: 16) {
                    CharterInfoSectionView(charter: charterInfoViewModel.charter,
                                           isLoading: charterInfoViewModel.isLoading)
                    SelectorRowView(dateLabel: formattedDate,
                                    guestsLabel: "\(charterInfoViewModel.groupSize) persons",
                                    onDateTap: { showDatePicker = true },
                                    onGuestsTap: { showGroupSizePicker = true })
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
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheetView(selectedDate: $charterInfoViewModel.selectedDate)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(.systemBackground))
        }
        .sheet(isPresented: $showGroupSizePicker) {
            GroupSizeSheetView(
                adults: $charterInfoViewModel.adults,
                children: $charterInfoViewModel.children
            )
            .presentationDetents([.height(280), .medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(.systemBackground))
        }
        .alert("Not yet implemented", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
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
