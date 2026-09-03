//
//  PackageAvailability.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 3. 9. 2026..
//

import Foundation

struct PackageAvailability: Decodable {
    let packageId: Int
    let available: Bool
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case packageId = "package_id"
        case available
        case reason
    }
}
