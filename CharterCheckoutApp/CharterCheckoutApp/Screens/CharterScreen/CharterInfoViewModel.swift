//
//  CharterInfoViewModel.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import Combine

@Observable
class CharterInfoViewModel {
    
    var charter: Charter?
    var packages: [Package] = []
    var isLoading = false
    var errorMessage: String?
    var selectedDate: Date = Date()
    var adults: Int = 2
    var children: Int = 0
    var groupSize: Int { adults + children }
    
    // MARK: - Methods
    
    func getCharterInfo() async {
        isLoading = true
        defer { isLoading = false }
        do {
            charter = try await APIManager.shared.getCharterInfo()
        } catch {
            errorMessage = "Couldn't load charter info."
        }
    }
    
    func getPackagesList() async {
        isLoading = true
        defer { isLoading = false }
        do {
            packages = try await APIManager.shared.getPackages()
        } catch {
            errorMessage = "Couldn't load trips."
        }
    }
}
