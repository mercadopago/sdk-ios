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
        self.decimalPart = decimalPart == "00" ? "" : decimalPart
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

    package init(from value: Decimal) {
        self.init(from: value, currencySymbol: MPStrings.Common.currency)
    }

    package init(from value: Decimal, currencySymbol: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let formatted = formatter.string(from: value as NSDecimalNumber) ?? NSDecimalNumber(decimal: value).stringValue
        let separator = formatter.decimalSeparator ?? ","
        let parts = formatted.components(separatedBy: separator)

        let decimal = parts.count > 1 ? parts[1] : "00"
        self.currencySymbol = currencySymbol
        self.integerPart = parts.first ?? formatted
        self.decimalPart = decimal == "00" ? "" : decimal
    }

    /// Parses a pre-formatted amount string (e.g. `"$ 15"`, `"R$ 1.250,99"`) into its display parts.
    ///
    /// The currency symbol is everything before the first digit. The decimal part is identified
    /// by a trailing separator followed by exactly 2 digits — grouping separators (3 digits after)
    /// are kept as part of the integer portion.
    package init(fromFormatted string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)

        guard let firstDigitIndex = trimmed.firstIndex(where: { $0.isNumber }) else {
            self.currencySymbol = trimmed
            self.integerPart = ""
            self.decimalPart = ""
            return
        }

        self.currencySymbol = String(trimmed[trimmed.startIndex..<firstDigitIndex])
            .trimmingCharacters(in: .whitespaces)

        let numberPart = String(trimmed[firstDigitIndex...])

        if let lastSep = numberPart.lastIndex(where: { $0 == "," || $0 == "." }) {
            let afterSep = String(numberPart[numberPart.index(after: lastSep)...])
            if afterSep.count == 2, afterSep.allSatisfy({ $0.isNumber }) {
                self.integerPart = String(numberPart[..<lastSep])
                self.decimalPart = afterSep == "00" ? "" : afterSep
                return
            }
        }

        self.integerPart = numberPart
        self.decimalPart = ""
    }
}
