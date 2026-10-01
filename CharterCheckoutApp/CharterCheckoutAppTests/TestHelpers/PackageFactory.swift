//
//  PackageFactory.swift
//  CharterCheckoutAppTests
//
//  Created by Branislav Manojlovic on 1. 10. 2026..
//

import Foundation

@testable import CharterCheckoutApp

func makePackage(
    id: String = "1",
    title: String = "Trip",
    price: Double = 100,
    currency: String = "USD",
    hours: Double = 4,
    minPersons: Int = 1,
    maxPersons: Int? = 4,
    packageType: String = "D"
) -> Package {
    Package(id: id, title: title, description: "desc", price: price, currency: currency,
            hours: hours, minPersons: minPersons, maxPersons: maxPersons, packageType: packageType)
}
