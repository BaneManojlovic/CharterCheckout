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
}

@Observable
final class APIManager: APIManagerProtocol {
    
    var isLoading = false
    
    static let shared = APIManager()
    
    private init() {}
    
    func getCharterInfo() async throws -> Charter {
        isLoading = true
        
        guard let url = URL(string: "https://fishingbooker.com/api/proxy/charters/1128?fields=title,description") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let wrapper = try JSONDecoder().decode(APIResponse<Charter>.self, from: data)
        return wrapper.data
    }
    
    func getPackages() async throws -> [Package] {
        isLoading = true
        
        guard let url = URL(string: "https://fishingbooker.com/api/proxy/packages?charter_id=1128&fields=id,price,min_persons,max_persons,hours,currency,title,description,package_type") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let wrapper = try JSONDecoder().decode(APIResponse<[Package]>.self, from: data)
        
        return wrapper.data
    }
    
    func getCharterPhotos() async throws -> [CharterPhoto] {
        guard let url = URL(string: "https://fishingbooker.com/api/proxy/charter_photos?charter_id=1128") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let wrapper = try JSONDecoder().decode(APIResponse<[CharterPhoto]>.self, from: data)
        return wrapper.data
    }
}
