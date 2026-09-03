//
//  Strings.swift
//  CharterCheckoutApp
//
//  Created by Branislav Manojlovic on 3. 9. 2026..
//

import Foundation

enum Strings {

    enum Charter {
        static let availableTrips = "Available trips"
        static let tooSoonToBook = "Too soon to book"
        static let notAvailable = "Not available"
        static let dateSelectorLabel = "Date"
        static let guestsSelectorLabel = "Guests"

        static func guestsLabel(_ count: Int) -> String {
            "\(count) persons"
        }
        static func minPersonsReason(_ count: Int) -> String {
            "Min \(count) people"
        }
        static func maxPersonsReason(_ count: Int) -> String {
            "Max \(count) people"
        }
    }

    enum Common {
        static let notYetImplementedTitle = "Not yet implemented"
        static let ok = "OK"
    }

    enum Checkout {
        static let title = "Checkout"
        
        static let yourDetails = "Your Details"
        static let paymentOption = "Payment Option"
        static let cardDetails = "Card Details"
        
        static let firstNamePlaceholder = "First name"
        static let firstNameRequired = "First name is required"
        
        static let lastNamePlaceholder = "Last name"
        static let lastNameRequired = "Last name is required"
        
        static let emailPlaceholder = "Email"
        static let emailInvalid = "Enter a valid email address"
        
        static let phonePlaceholder = "Phone number"
        static let phoneInvalid = "Enter a valid phone number"
        
        static let cardNumberPlaceholder = "Card number"
        static let cardNumberInvalid = "Enter a valid card number"
        
        static let expiryPlaceholder = "MM/YY"
        static let expiryInvalid = "Invalid expiry"
        
        static let cvvPlaceholder = "CVV"
        static let cvvInvalid = "Invalid CVV"
        
        static let cardholderNamePlaceholder = "Cardholder name"
        static let cardholderNameRequired = "Cardholder name is required"
        
        static let confirmBooking = "Confirm Booking"
        static let fixHighlightedFields = "Please fix the highlighted fields above"
        static let totalLabel = "Total"
        
        static func chargeTodayLabel(_ amount: String) -> String {
            "Charge \(amount) today"
        }
        
        static func depositLabel(depositAmount: String, remainingAmount: String) -> String {
            "Pay \(depositAmount) now, \(remainingAmount) due later"
        }
    }
    
    enum Sheets {
        static let selectDate = "Select date"
        static let confirm = "Confirm"
        static let howManyPeople = "How many people?"
        static let adults = "Adults"
        static let adultsSubtitle = "Ages 13 or above"
        static let children = "Children"
        static let childrenSubtitle = "Ages 2–12"
    }
    
    enum Trip {
        static let noPersonLimit = "up to no limit"
        static let perTrip = "per trip"
        static let reserve = "Reserve"
        static let unavailable = "Unavailable"
        static let yourTrip = "Your Trip"

        static func upToPersonsLabel(_ max: Int) -> String {
            "up to \(max)"
        }
        
        static func guestsCountLabel(_ count: Int) -> String {
                "\(count) guests"
        }
    }
    
    enum Confirmation {
        static let bookingConfirmedTitle = "Booking Confirmed!"
        static func referenceLabel(_ reference: String) -> String {
            "Reference: \(reference)"
        }
        static let done = "Done"
    }
    
    enum Errors {
        static let couldNotLoadCharter = "Couldn't load this charter. Check your connection and try again."
        static let retry = "Retry"
    }
}
