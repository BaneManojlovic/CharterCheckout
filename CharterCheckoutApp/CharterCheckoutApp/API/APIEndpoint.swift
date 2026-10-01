//
//  APIEndpoint.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 30. 9. 2026..
//

import Foundation

enum APIEndpoint {
    
    static let baseURL = "https://fishingbooker.com/api/proxy"
    static let charterId = 1128
    
    case charterInfo
    case packages
    case charterPhotos
    case packageAvailabilites(date: Date, groupSize: Int)
    
    var url: URL? {
        var components = URLComponents(string: "\(Self.baseURL)\(path)")
        components?.queryItems = queryItems
        return components?.url
    }
    
    private var path: String {
        switch self {
        case .charterInfo: return "/charters/\(Self.charterId)"
        case .packages: return "/packages"
        case .charterPhotos: return "/charter_photos"
        case .packageAvailabilites: return "/package_availabilities"
        }
    }
    
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .charterInfo:
            return [URLQueryItem(name: "fields", value: "title,description")]
        case .packages:
            return [
                URLQueryItem(name: "charter_id", value: "\(Self.charterId)"),
                URLQueryItem(name: "fields", value: "id,price,min_persons,max_persons,hours,currency,title,description,package_type")
            ]
        case .charterPhotos:
            return [URLQueryItem(name: "charter_id", value: "\(Self.charterId)")]
        case .packageAvailabilites(let date, let groupSize):
            return [
                URLQueryItem(name: "charter_id", value: "\(Self.charterId)"),
                URLQueryItem(name: "trip_date", value: date.apiDateString),
                URLQueryItem(name: "group_size", value: "\(groupSize)"),
                URLQueryItem(name: "booking_days", value: "1")
            ]
        }
    }
}
