//
//  APIServiceManager.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation
import Combine
import Observation

protocol APIManagerProtocol: AnyObject {
    func getCharterInfo() async throws -> Charter
    func getPackages() async throws -> [Package]
    func getCharterPhotos() async throws -> [CharterPhoto]
    func getPackageAvailabilities(date: Date, groupSize: Int) async throws -> [String: PackageAvailability]
}

@Observable
final class APIManager: APIManagerProtocol {
    
    static let shared = APIManager()
    
    private init() {}
    
    private func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let wrapper = try JSONDecoder().decode(APIResponse<T>.self, from: data)
        return wrapper.data
    }
    
    
    func getCharterInfo() async throws -> Charter {
        try await fetch(.charterInfo)
    }
    
    func getPackages() async throws -> [Package] {
        try await fetch(.packages)
    }
    
    func getCharterPhotos() async throws -> [CharterPhoto] {
        try await fetch(.charterPhotos)
    }
    
    func getPackageAvailabilities(date: Date, groupSize: Int) async throws -> [String : PackageAvailability] {
        try await fetch(.packageAvailabilites(date: date, groupSize: groupSize))
    }
}
