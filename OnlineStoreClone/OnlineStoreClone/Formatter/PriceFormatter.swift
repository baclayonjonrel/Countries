//
//  PriceFormatter.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/21/24.
//

import Foundation

class PriceFormatter {
    static let shared = PriceFormatter()
    
    private let formatter: NumberFormatter

    private init() {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale.current
    }
    
    func format(price: Decimal) -> String {
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? ""
    }
}
