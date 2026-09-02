//
//  View+Extension.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation
import SwiftUI

// TODO: - implement this for validation on Checkout view fields

extension View {
    func filteringInput(_ text: Binding<String>, using filter: @escaping (String) -> String) -> some View {
        onChange(of: text.wrappedValue) { _, newValue in
            let filtered = filter(newValue)
            if filtered != newValue { text.wrappedValue = filtered }
        }
    }
}

enum InputFilter {
    static func digitsOnly(_ text: String, maxLength: Int? = nil) -> String {
        let filtered = text.filter(\.isNumber)
        guard let maxLength else { return filtered }
        return String(filtered.prefix(maxLength))
    }

    /// "1234" typed → "12/34" as you go
    static func expiryFormatted(_ text: String) -> String {
        let digits = String(text.filter(\.isNumber).prefix(4))
        guard digits.count > 2 else { return digits }
        let month = digits.prefix(2)
        let year = digits.suffix(digits.count - 2)
        return "\(month)/\(year)"
    }

    /// "4111111111111111" typed → "4111 1111 1111 1111" as you go
    static func cardNumberFormatted(_ text: String) -> String {
        let digits = String(text.filter(\.isNumber).prefix(19))
        return digits.enumerated().map { index, char in
            index != 0 && index % 4 == 0 ? " \(char)" : String(char)
        }.joined()
    }
}
