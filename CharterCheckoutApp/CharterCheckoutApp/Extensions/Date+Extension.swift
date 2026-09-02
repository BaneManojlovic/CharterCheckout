//
//  Date+Extension.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation

extension Date {

    var formattedShort: String {
        formatted(.dateTime.month(.abbreviated).day())
    }
}
