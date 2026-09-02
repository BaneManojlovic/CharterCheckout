//
//  CharterPhoto.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation

struct CharterPhoto: Decodable, Identifiable {
    let id: String
    let cardinal: Int   // display order — API sends it as a string, same drill as `price`
    let imageURL: String

    private enum CodingKeys: String, CodingKey {
        case id, cardinal, urls
    }
    private enum URLKeys: String, CodingKey {
        case m
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        let cardinalString = try container.decode(String.self, forKey: .cardinal)
        cardinal = Int(cardinalString) ?? 0

        let urlsContainer = try container.nestedContainer(keyedBy: URLKeys.self, forKey: .urls)
        imageURL = try urlsContainer.decode(String.self, forKey: .m)
    }
}
