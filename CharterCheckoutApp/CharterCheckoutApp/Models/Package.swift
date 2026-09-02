//
//  Package.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation

struct Package: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let hours: Double
    let minPersons: Int
    let maxPersons: Int?
    let packageType: String
    let currency: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, hours, currency
        case minPersons = "min_persons"
        case maxPersons = "max_persons"
        case packageType = "package_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        hours = try container.decode(Double.self, forKey: .hours)
        minPersons = try container.decode(Int.self, forKey: .minPersons)
        maxPersons = try container.decodeIfPresent(Int.self, forKey: .maxPersons)
        packageType = try container.decode(String.self, forKey: .packageType)
        currency = try container.decode(String.self, forKey: .currency)

        // TODO: - Review this
        // price comes back as a quoted string ("925"), not a JSON number —
        // convert it here so everywhere else in the app just sees a Double.
        let priceString = try container.decode(String.self, forKey: .price)
        guard let priceValue = Double(priceString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .price, in: container,
                debugDescription: "Expected a numeric string for price, got \"\(priceString)\""
            )
        }
        price = priceValue
    }
}
