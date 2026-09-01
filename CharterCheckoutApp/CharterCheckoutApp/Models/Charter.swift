//
//  Charter.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation

struct Charter: Decodable {
    let title: String
    let description: String
    var location: String?
    var rating: Double?
    var reviewCount: Int?
}
