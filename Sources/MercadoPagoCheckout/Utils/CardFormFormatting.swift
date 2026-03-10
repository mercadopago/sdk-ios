//
//  CardFormFormatting.swift
//  MercadoPagoSDK
//
//  Created by SDK on 12/12/25.
//

import Foundation
import MPComponents

// MARK: - Card Number Formatter

/// A formatter that applies a mask pattern to card numbers.
package struct CardNumberFormatter: TextFormatting {
    private static let maskByLength: [Int: String] = [
        8: "#### ####",
        9: "#### #####",
        10: "#### ######",
        11: "#### #### ###",
        12: "#### #### ####",
        13: "#### ###### ###",
        14: "#### ###### ####",
        15: "#### ###### #####",
        16: "#### #### #### ####",
        17: "#### #### #### #####",
        18: "#### #### #### ######",
        19: "#### #### #### #### ###"
    ]
    private static let defaultMask = "#### #### #### ####"

    private let maskFormat: String
    private let maxLength: Int

    /// Creates a card number formatter for the specified max digit count.
    /// The mask is automatically selected based on `maxLength`.
    /// - Parameter maxLength: Maximum number of digits accepted. Default is 16.
    package init(maxLength: Int = 16) {
        self.maxLength = maxLength
        self.maskFormat = Self.maskByLength[maxLength] ?? Self.defaultMask
    }

    package func formatOnChange(_ text: String) -> String {
        let cleanNumber = String(
            text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().prefix(self.maxLength)
        )
        var result = ""
        var index = cleanNumber.startIndex

        for char in self.maskFormat where index < cleanNumber.endIndex {
            if char == "#" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(char)
            }
        }

        return result
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}

// MARK: - Expiration Date Formatter

/// A formatter that applies MM/YY mask to expiration dates.
package struct ExpirationDateFormatter: TextFormatting {
    package init() {}

    package func formatOnChange(_ text: String) -> String {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        guard !digits.isEmpty else { return "" }

        let limited = String(digits.prefix(4))

        if limited.count <= 2 {
            return limited
        }

        let month = String(limited.prefix(2))
        let year = String(limited.dropFirst(2))

        return "\(month)/\(year)"
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}

// MARK: - Document Formatter

/// A formatter that applies a mask pattern to document numbers.
/// Uses '#' for digit positions and any other character as a literal.
/// When the format is empty, the input is returned unchanged.
package struct DocumentFormatter: TextFormatting {
    private let maskFormat: String
    private let maxLength: Int

    package init(mask: String = "", maxLength: Int = 20) {
        self.maskFormat = mask
        self.maxLength = maxLength
    }

    package func formatOnChange(_ text: String) -> String {
        guard !self.maskFormat.isEmpty else {
            return String(text.prefix(self.maxLength))
        }
        let digits = String(
            text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().prefix(self.maxLength)
        )
        var result = ""
        var index = digits.startIndex

        for char in self.maskFormat where index < digits.endIndex {
            if char == "#" {
                result.append(digits[index])
                index = digits.index(after: index)
            } else {
                result.append(char)
            }
        }

        return result
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}

// MARK: - Security Code Formatter

/// A formatter that limits CVV input to digits only.
package struct SecurityCodeFormatter: TextFormatting {
    private let maxLength: Int

    /// Creates a security code formatter.
    /// - Parameter maxLength: Maximum digits allowed. Default is 4 (for Amex).
    package init(maxLength: Int = 4) {
        self.maxLength = maxLength
    }

    package func formatOnChange(_ text: String) -> String {
        let digits = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return String(digits.prefix(self.maxLength))
    }

    package func formatOnCommit(_ text: String) -> String {
        self.formatOnChange(text)
    }
}
