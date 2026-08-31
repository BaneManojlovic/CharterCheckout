//
//  Item.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 31. 8. 2026..
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
