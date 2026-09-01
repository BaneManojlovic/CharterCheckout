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
        List {
            if let charter = charterInfoViewModel.charter {
                Section("Charter") {
                    Text(charter.title)
                    Text(charter.description)
                        .lineLimit(2)
                        .truncationMode(.tail)

                }
            } else if charterInfoViewModel.isLoading {
                ProgressView()
            }
            
            Section("Packages") {
                ForEach(charterInfoViewModel.packages) { package in
                    Text(package.title)
                }
            }
            
        }
        .task {
            await charterInfoViewModel.getCharterInfo()
            await charterInfoViewModel.getPackagesList()
        }
    }
}
