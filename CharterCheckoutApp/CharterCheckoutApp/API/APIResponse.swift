//
//  APIResponse.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 1. 9. 2026..
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let data: T
    let code: Int
}
