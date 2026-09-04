//
//  Date+Extension.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation

extension Date {

    var formattedShort: String {
        formatted(.dateTime.month(.abbreviated).day()
            .locale(Locale(identifier: "en_US")))
    }
    
    var apiDateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter.string(from: self)
    }
}
