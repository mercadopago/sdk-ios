//
//  MPAmountData.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 10/03/26.
//
import Foundation
import MPFoundation

/// Structured representation of a monetary amount split into display parts.
///
/// Pre-split the value so the footer can render each part with independent typography
/// (e.g., a smaller superscript for the decimal portion).
///
/// ```swift
/// MPAmountData(currencySymbol: "R$", integerPart: "1.250", decimalPart: "00")
/// ```
package struct MPAmountData: Equatable {
    /// Currency symbol (e.g., `"R$"`, `"$"`).
    var currencySymbol: String
    /// Integer portion of the amount (e.g., `"1.250"`).
    var integerPart: String
    /// Decimal portion of the amount, without separator (e.g., `"00"`, `"99"`).
    var decimalPart: String

    package init(currencySymbol: String, integerPart: String, decimalPart: String) {
        self.currencySymbol = currencySymbol
        self.integerPart = integerPart
        self.decimalPart = decimalPart
    }

    /// Creates an `MPAmountData` by splitting a `Double` amount into its display parts.
    ///
    /// Uses the device locale for number formatting (grouping separators) and the
    /// localized currency symbol from `MPStrings.Common.currency`.
    ///
    /// ```swift
    /// MPAmountData(from: 1250.99)
    /// // → currencySymbol: "R$", integerPart: "1.250", decimalPart: "99"
    /// ```
    package init(from value: Double) {
        self.init(from: value, currencySymbol: MPStrings.Common.currency)
    }

    package init(from value: Double, currencySymbol: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        let separator = formatter.decimalSeparator ?? ","
        let parts = formatted.components(separatedBy: separator)

        let decimal = parts.count > 1 ? parts[1] : "00"
        self.currencySymbol = currencySymbol
        self.integerPart = parts.first ?? formatted
        self.decimalPart = decimal == "00" ? "" : decimal
    }
}
