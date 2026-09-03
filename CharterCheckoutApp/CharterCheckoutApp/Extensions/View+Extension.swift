//
//  View+Extension.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

extension View {
    func filteringInput(_ text: Binding<String>, using filter: @escaping (String) -> String) -> some View {
        onChange(of: text.wrappedValue) { _, newValue in
            let filtered = filter(newValue)
            if filtered != newValue { text.wrappedValue = filtered }
        }
    }
}

enum InputFilter {

    static func phoneFiltered(_ text: String, maxLength: Int = 15) -> String {
            let hasLeadingPlus = text.hasPrefix("+")
            let digits = String(text.filter(\.isNumber).prefix(maxLength))
            return hasLeadingPlus ? "+\(digits)" : digits
    }

    static func digitsOnly(_ text: String, maxLength: Int? = nil) -> String {
        let filtered = text.filter(\.isNumber)
        guard let maxLength else { return filtered }
        return String(filtered.prefix(maxLength))
    }

    static func expiryFormatted(_ text: String) -> String {
        let digits = String(text.filter(\.isNumber).prefix(4))
        guard digits.count > 2 else { return digits }
        return "\(digits.prefix(2))/\(digits.suffix(digits.count - 2))"
    }

    static func cardNumberFormatted(_ text: String) -> String {
        let digits = String(text.filter(\.isNumber).prefix(19))
        return digits.enumerated().map { index, char in
            index != 0 && index % 4 == 0 ? " \(char)" : String(char)
        }.joined()
    }
}
