//
//  CustomerDetails.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 2. 9. 2026..
//

import Foundation

struct CustomerDetails {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
}

struct CreditCardDetails {
    var number = ""
    var expiry = ""
    var cvv = ""
    var cardholderName = ""
}

enum PaymentOption: String, CaseIterable, Identifiable {
    case full, deposit
    var id: String { rawValue }
    var label: String {
        switch self {
        case .full: return "Pay 100% now"
        case .deposit: return "Pay deposit now, rest later"
        }
    }
}
