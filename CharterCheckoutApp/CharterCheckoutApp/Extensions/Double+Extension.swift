//
//  Double+Extension.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation

extension Double {

    func asCurrencyString(code: String) -> String {
        formatted(
            .currency(code: code)
                .locale(Locale(identifier: "en_US"))
                .precision(.fractionLength(0...2))
        )
    }
}
